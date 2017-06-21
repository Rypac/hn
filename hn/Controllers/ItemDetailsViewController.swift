import UIKit
import AsyncDisplayKit
import ReSwift

final class ItemDetailsViewController: ASViewController<ASDisplayNode>, StoreSubscriber {
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }

    var item: Item
    var comments = [Item]()
    var fetchingMore = false
    var hasMoreComments = true
    var fetchingContext: ASBatchContext?

    init(_ item: Item) {
        self.item = item
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = item.title
        store.subscribe(self) { subscription in
            subscription.select { state in state.selectedItem! }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if case .none = parent {
            store.dispatch(ItemListAction.dismiss(item))
        }
    }

    func newState(state: ItemDetails) {
        let wasFetchingMore = fetchingMore
        let oldComments = comments
        item = state.item
        comments = state.comments
        fetchingMore = state.fetchingMore

        tableNode.performBatchUpdates({
            let rowCountChange = comments.count - oldComments.count
            if rowCountChange > 0 {
                let indexPaths = (oldComments.count..<comments.count).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableNode.insertRows(at: indexPaths, with: .none)
            }

            if fetchingMore != wasFetchingMore {
                if fetchingMore {
                    tableNode.insertRows(
                        at: [IndexPath(row: comments.count, section: 0)],
                        with: .none)
                } else {
                    tableNode.deleteRows(
                        at: [IndexPath(row: oldComments.count, section: 0)],
                        with: .none)
                    fetchingContext?.completeBatchFetching(true)
                }
            }
        }, completion: nil)
    }
}

extension ItemDetailsViewController: ASTableDataSource, ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return hasMoreComments
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.fetchingContext = context
        store.dispatch(fetchNextCommentBatch)
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 0)

        if fetchingMore && indexPath.row == rowCount - 1 {
            return {
                let node = LoadingCellNode()
                node.style.height = ASDimensionMake(44.0)
                return node
            }
        }

        let comment = comments[indexPath.row]
        return {
            let node = CommentCellNode()
            if
                let author = comment.by,
                let text = comment.text,
                let time = comment.time
            {
                node.update(comment: text, author: author, timestamp: time)
            }
            return node
        }
    }

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return fetchingMore ? comments.count + 1 : comments.count
    }
}
