import AsyncDisplayKit
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

    init(_ item: Item) {
        state = ItemDetailsViewModel(details: ItemDetails(item))
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.view.refreshControl = refreshControl
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self) { subscription in
            subscription.select { state in ItemDetailsViewModel(details: state.selectedItem!) }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if case .none = parent {
            store.dispatch(ItemListAction.dismiss(state.item))
        }
    }

    func refreshData(sender: UIRefreshControl) {
        store.dispatch(fetchComments(forItem: state.item))
    }
}

extension ItemDetailsViewController: StoreSubscriber {
    func newState(state newState: ItemDetailsViewModel) {
        let previous = state.comments.count
        let current = newState.comments.count
        let fetching = newState.fetching
        let offset = newState.headerOffset

        state = newState
        title = newState.title

        tableNode.performBatchUpdates({
            let indexPath = { IndexPath(row: $0, section: 0) }
            switch fetching {
            case .some(.started):
                if previous > offset {
                    tableNode.deleteRows(at: (offset..<previous).map(indexPath), with: .none)
                }
                if current == offset {
                    tableNode.insertRows(at: [indexPath(current)], with: .none)
                }
            case .some(.finished):
                if refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
                if previous == offset {
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
    }
}

extension ItemDetailsViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        switch state.fetching {
        case .some(.started):
            return state.comments.count + 1
        default:
            return state.comments.count
        }
    }

    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return state.hasMoreItems
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if indexPath.row >= state.comments.count {
            return {
                let node = LoadingCellNode()
                node.style.height = ASDimensionMake(44.0)
                return node
            }
        }

        let row = indexPath.row
        let comment = state.comments[row]
        let item = comment.item
        let headerOffset = state.headerOffset
        return {
            let node = row < headerOffset ? ItemDetailCellNode(item) : CommentCellNode(comment)
            node.selectionStyle = .none
            return node
        }
    }

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        fetchingContext = context
        store.dispatch(fetchComments(forItem: state.item))
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < state.headerOffset {
            routeTo(original: state.item, from: self)
        }
    }
}
