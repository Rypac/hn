import AsyncDisplayKit
import IGListKit
import ReSwift
import UIKit

final class ItemDetailsViewController: ASViewController<ASDisplayNode> {
    var tableNode: ASTableNode {
        return node as! ASTableNode // swiftlint:disable:this force_cast
    }

    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshData(sender:)), for: .valueChanged)
        return refresh
    }()

    var state: ItemDetailsViewModel
    var fetchingContext: ASBatchContext?

    init(_ post: Post) {
        state = ItemDetailsViewModel(details: ItemDetails(post))
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.view.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select { state in
                ItemDetailsViewModel(details: state.selectedItem!)
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == .none {
            store.dispatch(ItemListNavigationAction.dismiss(state.parent))
        }
    }

    func refreshData(sender: UIRefreshControl) {
        store.dispatch(fetchComments(forPost: state.parent))
    }
}

extension ItemDetailsViewController: StoreSubscriber {
    func newState(state newState: ItemDetailsViewModel) {
        let oldComments = state.comments
        state = newState
        title = newState.title

        if newState.fetching == .finished {
            refreshControl.endRefreshing()
            fetchingContext?.completeBatchFetching(true)
        }

        let diff = ListDiffPaths(
            fromSection: 1,
            toSection: 1,
            oldArray: oldComments,
            newArray: state.comments,
            option: .equality)
        if diff.hasChanges {
            tableNode.performBatchUpdates({
                tableNode.deleteRows(at: diff.deletes, with: .bottom)
                tableNode.insertRows(at: diff.inserts, with: .bottom)
                tableNode.reloadRows(at: diff.updates, with: .automatic)
                for move in diff.moves {
                    tableNode.moveRow(at: move.from, to: move.to)
                }
            })
        }
    }
}

extension ItemDetailsViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return section == ItemDetailsViewModel.Section.comments.rawValue
            ? state.comments.count
            : 1
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if indexPath.as(ItemDetailsViewModel.Section.self) == .parent {
            let parent = state.parent
            return {
                let node = ItemDetailCellNode(parent)
                node.selectionStyle = .none
                return node
            }
        }

        let comment = state.comments[indexPath.row].comment
        return {
            let node = CommentCellNode(comment)
            node.selectionStyle = .none
            return node
        }
    }
}

extension ItemDetailsViewController: ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return state.hasMoreComments
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        fetchingContext = context
        store.dispatch(fetchComments(forPost: state.parent))
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.as(ItemDetailsViewModel.Section.self) {
        case .parent?:
            routeTo(original: state.parent, from: self)
        case .comments?:
            let comment = state.comments[indexPath.row].comment
            store.dispatch(CommentItemAction.collapse(comment))
        default:
            break
        }
    }
}
