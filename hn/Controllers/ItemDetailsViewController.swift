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

    init(state: ItemDetailsViewModel) {
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
        tableNode.view.refreshControl = refreshControl

        let longPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(longPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.35
        longPressGesture.delegate = self
        tableNode.view.addGestureRecognizer(longPressGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select { state in
                ItemDetailsViewModel(details: state.selectedItem!, repo: state.repository)
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
        store.dispatch(fetchComments(state.repo.fetchItem)(state.parent.id))
    }
}

extension ItemDetailsViewController: UIGestureRecognizerDelegate {
    func longPress(gesture: UILongPressGestureRecognizer) {
        guard
            gesture.state == UIGestureRecognizerState.began,
            let index = tableNode.indexPathForRow(at: gesture.location(in: tableNode.view)),
            index.as(ItemDetailsViewModel.Section.self) == .comments
        else {
            return
        }

        let comment = state.comments[index.row].comment
        if !comment.actions.collapsed {
            store.dispatch(CommentItemAction.collapse(comment))
        }
    }
}

extension ItemDetailsViewController: StoreSubscriber {
    func newState(state newState: ItemDetailsViewModel) {
        let oldComments = state.comments
        state = newState
        title = newState.title

        if newState.fetching == .finished {
            refreshControl.endRefreshing()
        }

        let diff = ListDiffPaths(
            fromSection: 1,
            toSection: 1,
            oldArray: oldComments,
            newArray: state.comments,
            option: .equality)
        if diff.hasChanges {
            tableNode.performBatchUpdates({
                for indexPath in diff.updates {
                    if let node = tableNode.nodeForRow(at: indexPath) as? CommentCellNode {
                        node.bind(viewModel: state.comments[indexPath.row])
                        node.transitionLayout(withAnimation: true, shouldMeasureAsync: true)
                    }
                }
                tableNode.deleteRows(at: diff.deletes, with: .fade)
                tableNode.insertRows(at: diff.inserts, with: .fade)
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
                let node = ItemDetailCellNode(viewModel: parent)
                node.selectionStyle = .none
                return node
            }
        }

        let comment = state.comments[indexPath.row]
        return {
            let node = CommentCellNode(viewModel: comment)
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
        store.dispatch(async: fetchComments(state.repo.fetchItem)(state.parent.id)).regardless {
            context.completeBatchFetching(true)
        }
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.as(ItemDetailsViewModel.Section.self) {
        case .parent?:
            if let viewOriginalAction = routeTo(original: state.parent, from: self) {
                store.dispatch(viewOriginalAction)
            }
        case .comments?:
            let comment = state.comments[indexPath.row].comment
            if comment.actions.collapsed {
                store.dispatch(CommentItemAction.expand(comment))
            }
        default:
            break
        }
    }
}
