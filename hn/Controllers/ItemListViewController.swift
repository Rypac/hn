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

    var state: ItemListViewModel

    init(state: ItemListViewModel) {
        self.state = state
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
        let type = state.itemType
        parent?.title = type.description
        store.subscribe(self) { subscription in
            subscription.select { state in
                ItemListViewModel(
                    type: type,
                    list: state.tabs[type]!,
                    details: state.selectedItem,
                    repo: state.repository)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    func refreshData(sender: UIRefreshControl) {
        store.dispatch(fetchItemList(state.repo.fetchItems)(state.itemType))
    }

    func longPress(gesture: UILongPressGestureRecognizer) {
        guard
            gesture.state == UIGestureRecognizerState.began,
            let index = tableNode.indexPathForRow(at: gesture.location(in: tableNode.view))
        else {
            return
        }

        let story = state.posts[index.row].post
        if let viewOriginalAction = routeTo(original: story, from: self) {
            store.dispatch(viewOriginalAction)
        }
    }
}

extension ItemListViewController: StoreSubscriber {
    func newState(state newState: ItemListViewModel) {
        let oldPosts = state.posts
        state = newState

        switch newState.fetching {
        case .none:
            refreshControl.beginRefreshing()
            store.dispatch(fetchItemList(state.repo.fetchItems)(state.itemType))
        case .list(.finished)?:
            store.dispatch(fetchNextItemBatch(state.repo.fetchItem)(state.itemType))
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
        store.dispatch(async: fetchNextItemBatch(state.repo.fetchItem)(state.itemType)).regardless {
            context.completeBatchFetching(true)
        }
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let story = state.posts[indexPath.row].post
        store.dispatch(routeTo(story, from: self))
        tableNode.deselectRow(at: indexPath, animated: true)
    }
}

extension ItemListViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        store.dispatch(ItemListNavigationAction.dismissOriginal)
    }
}
