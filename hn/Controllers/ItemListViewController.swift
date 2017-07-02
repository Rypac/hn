import AsyncDisplayKit
import Dwifft
import ReSwift
import SafariServices
import UIKit

final class ItemListViewController: ASViewController<ASDisplayNode>, UIGestureRecognizerDelegate {
    var tableNode: ASTableNode {
        return node as! ASTableNode // swiftlint:disable:this force_cast
    }

    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        return refresh
    }()

    let itemType: ItemType
    var state = ItemListViewModel()
    var diffCalculator = ASTableNodeDiffCalculator<ItemListViewModel.Section, Item>()
    var fetchingContext: ASBatchContext?

    init(_ storyType: ItemType) {
        self.itemType = storyType
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
        diffCalculator.tableNode = tableNode
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
        let type = itemType
        store.subscribe(self) { subscription in
            subscription.select { state in
                ItemListViewModel(list: state.tabs[type]!, details: state.selectedItem)
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
        routeTo(original: story, from: self)
    }
}

extension ItemListViewController: StoreSubscriber {
    func newState(state newState: ItemListViewModel) {
        state = newState

        switch newState.fetching {
        case .none:
            refreshControl.manuallyBeginRefreshing(inView: tableNode.view)
        case .some(.items(.finished)):
            refreshControl.endRefreshing()
            fetchingContext?.completeBatchFetching(true)
        default:
            break
        }

        diffCalculator.sectionedValues = SectionedValues([(.items, newState.items)])

        if case .none = newState.selectedItem, let index = tableNode.indexPathForSelectedRow {
            tableNode.deselectRow(at: index, animated: true)
        }
    }
}

extension ItemListViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return diffCalculator.numberOfSections()
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator.numberOfObjects(inSection: section)
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let item = diffCalculator.value(atIndexPath: indexPath)
        return {
            return ItemCellNode(item)
        }
    }
}

extension ItemListViewController: ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return state.hasMoreItems
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        fetchingContext = context
        store.dispatch(fetchItems(itemType))
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let story = state.items[indexPath.row]
        routeTo(story, from: self)
    }
}

extension ItemListViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        store.dispatch(ItemListAction.dismissOriginal)
    }
}
