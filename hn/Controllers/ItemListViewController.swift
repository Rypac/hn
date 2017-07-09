import AsyncDisplayKit
import IGListKit
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

    init(_ storyType: ItemType) {
        self.itemType = storyType
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
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

        let story = state.posts[index.row].post
        tableNode.selectRow(at: index, animated: false, scrollPosition: .none)
        routeTo(original: story, from: self)
    }
}

extension ItemListViewController: StoreSubscriber {
    func newState(state newState: ItemListViewModel) {
        let oldPosts = state.posts
        state = newState

        switch newState.fetching {
        case .list(.started)?:
            refreshControl.manuallyBeginRefreshing(inView: tableNode.view)
        case .list(.finished)?:
            store.dispatch(fetchItems(itemType))
        case .items(.finished)?:
            refreshControl.endRefreshing()
        default:
            break
        }

        let diff = ListDiffPaths(
            fromSection: 0,
            toSection: 0,
            oldArray: oldPosts,
            newArray: state.posts,
            option: .equality)
        if diff.hasChanges {
            tableNode.performBatchUpdates({
                tableNode.reloadRows(at: diff.updates, with: .automatic)
                tableNode.deleteRows(at: diff.deletes, with: .none)
                tableNode.insertRows(at: diff.inserts, with: .none)
                for move in diff.moves {
                    tableNode.moveRow(at: move.from, to: move.to)
                }
            })
        }

        if case .none = newState.selectedItem, let index = tableNode.indexPathForSelectedRow {
            tableNode.deselectRow(at: index, animated: true)
        }
    }
}

extension ItemListViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return state.posts.count
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let item = state.posts[indexPath.row].post
        return { ItemCellNode(viewModel: item) }
    }
}

extension ItemListViewController: ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return state.hasMoreItems
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        store.dispatch(async: fetchItems(itemType)).regardless {
            context.completeBatchFetching(true)
        }
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let story = state.posts[indexPath.row].post
        routeTo(story, from: self)
    }
}

extension ItemListViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        store.dispatch(ItemListNavigationAction.dismissOriginal)
    }
}
