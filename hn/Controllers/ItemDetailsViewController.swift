import AsyncDisplayKit
import Dwifft
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
    var diffCalculator = ASTableNodeDiffCalculator<ItemDetailsViewModel.Section, Comment>()
    var fetchingContext: ASBatchContext?

    init(_ item: Item) {
        state = ItemDetailsViewModel(details: ItemDetails(item))
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
        diffCalculator.tableNode = tableNode
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
            store.dispatch(ItemListAction.dismiss(state.parent.item))
        }
    }

    func refreshData(sender: UIRefreshControl) {
        store.dispatch(fetchComments(forItem: state.parent.item))
    }
}

extension ItemDetailsViewController: StoreSubscriber {
    func newState(state newState: ItemDetailsViewModel) {
        state = newState
        title = newState.title

        if newState.fetching == .finished {
            refreshControl.endRefreshing()
            fetchingContext?.completeBatchFetching(true)
        }

        diffCalculator.sectionedValues = SectionedValues([
            (.parent, [newState.parent]),
            (.comments, newState.comments)])
    }
}

extension ItemDetailsViewController: ASTableDataSource {
    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return diffCalculator.numberOfSections()
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return diffCalculator.numberOfObjects(inSection: section)
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if indexPath.as(ItemDetailsViewModel.Section.self) == .parent {
            let comment = diffCalculator.value(atIndexPath: indexPath)
            return {
                let node = ItemDetailCellNode(comment.item)
                node.selectionStyle = .none
                return node
            }
        }

        let comment = diffCalculator.value(atIndexPath: indexPath)
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
        store.dispatch(fetchComments(forItem: state.parent.item))
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        if indexPath.as(ItemDetailsViewModel.Section.self) == .parent {
            routeTo(original: state.parent.item, from: self)
        }
    }
}
