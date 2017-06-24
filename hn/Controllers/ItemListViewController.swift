import UIKit
import AsyncDisplayKit
import ReSwift
import SafariServices

final class ItemListViewController: ASViewController<ASDisplayNode>, UIGestureRecognizerDelegate {
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }

    lazy var refreshControl: UIRefreshControl = { [weak self] in
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        return refresh
    }()

    let itemType: ItemType
    var state = ItemListViewModel()
    var fetchingContext: ASBatchContext?

    init(_ storyType: ItemType) {
        self.itemType = storyType
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.leadingScreensForBatching = 1
        tableNode.view.refreshControl = refreshControl

        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        tableNode.view.addGestureRecognizer(longPressGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.title = itemType.description
        store.subscribe(self) { subscription in
            subscription.select { state in
                ItemListViewModel(list: state.tabs[self.itemType]!, details: state.selectedItem)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func refreshData(sender: UIRefreshControl) {
        store.dispatch(fetchItemList(itemType))
    }

    func longPress(gesture: UILongPressGestureRecognizer) {
        guard
            gesture.state == UIGestureRecognizerState.began,
            let index = tableNode.indexPathForRow(at: gesture.location(in: tableNode.view))
        else {
            return
        }

        let story = state.items[index.row]
        tableNode.selectRow(at: index, animated: false, scrollPosition: .none)
        store.dispatch(routeTo(original: story, from: self))
    }
}

extension ItemListViewController: StoreSubscriber {
    func newState(state newState: ItemListViewModel) {
        let previous = state.items.count
        let current = newState.items.count
        let fetching = newState.fetching

        state = newState

        tableNode.performBatchUpdates({
            let rows = tableNode.numberOfRows(inSection: 0)
            let indexPath = { IndexPath(row: $0, section: 0) }
            switch fetching {
            case .some(.list(.finished)):
                if refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
                if previous > 0 {
                    tableNode.deleteRows(at: (0..<previous).map(indexPath), with: .none)
                }
            case .some(.items(.started)):
                if rows == current {
                    tableNode.insertRows(at: [indexPath(current)], with: .none)
                }
            case .some(.items(.finished)):
                if rows > previous {
                    tableNode.deleteRows(at: [indexPath(previous)], with: .none)
                }
                if current > previous {
                    tableNode.insertRows(at: (previous..<current).map(indexPath), with: .none)
                }
                fetchingContext?.completeBatchFetching(true)
            default:
                break
            }
        })

        if
            case .none = newState.selectedItem,
            let selectedRow = tableNode.indexPathForSelectedRow
        {
            tableNode.deselectRow(at: selectedRow, animated: true)
        }
    }
}

extension ItemListViewController: ASTableDataSource, ASTableDelegate {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        switch state.fetching {
        case .some(.items(.started)):
            return state.items.count + 1
        default:
            return state.items.count
        }
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if indexPath.row >= state.items.count {
            return {
                let node = LoadingCellNode()
                node.style.height = ASDimensionMake(44.0)
                return node
            }
        }

        let item = state.items[indexPath.row]
        return {
            return ItemCellNode(item)
        }
    }

    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return state.hasMoreItems
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        fetchingContext = context
        store.dispatch(fetchItems(itemType))
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let story = state.items[indexPath.row]
        store.dispatch(routeTo(story, from: self))
    }
}

extension ItemListViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        store.dispatch(ItemListAction.dismissOriginal)
    }
}
