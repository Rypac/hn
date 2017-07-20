import AsyncDisplayKit
import ReSwift
import SafariServices
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
    var dataSource: ItemDetailsDataSource

    init(state: ItemDetailsViewModel) {
        self.state = state
        dataSource = ItemDetailsDataSource(state)
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = dataSource
        dataSource.delegate = self
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
        store.dispatch(state.requestComments)
    }
}

extension ItemDetailsViewController: StoreSubscriber {
    func newState(state newState: ItemDetailsViewModel) {
        dataSource.provider = newState
        state = newState
        title = newState.title

        if newState.fetching == .finished {
            refreshControl.endRefreshing()
        }

        if let diff = dataSource.diff, diff.hasChanges {
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

extension ItemDetailsViewController: ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return state.hasMoreComments
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        store.dispatch(async: state.requestComments).regardless {
            context.completeBatchFetching(true)
        }
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.as(ItemDetailsDataSource.Section.self) {
        case .parent?:
            if let viewOriginalAction = routeTo(original: dataSource.provider.parent, from: self) {
                store.dispatch(viewOriginalAction)
            }
        case .comments?:
            let comment = dataSource.provider.comments[indexPath.row].comment
            let action = comment.actions.collapsed
                ? CommentItemAction.expand
                : CommentItemAction.collapse
            store.dispatch(action(comment))
        default:
            break
        }
    }
}

extension ItemDetailsViewController: ASTextNodeDelegate {
    func textNode(
        _ textNode: ASTextNode,
        tappedLinkAttribute attribute: String,
        value: Any,
        at point: CGPoint,
        textRange: NSRange
    ) {
        guard
            let attributes = value as? Attributes,
            let link = attributes.find("href"),
            let url = URL(string: link)
        else {
            return
        }

        present(SFSafariViewController(url: url), animated: true, completion: nil)
    }

    func textNode(
        _ textNode: ASTextNode,
        shouldHighlightLinkAttribute attribute: String,
        value: Any,
        at point: CGPoint
    ) -> Bool {
        return true
    }
}
