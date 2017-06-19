import UIKit
import AsyncDisplayKit
import ReSwift

final class StoryDetailViewController: ASViewController<ASDisplayNode>, StoreSubscriber {
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }

    var story: Story
    var comments = [Comment]()
    var fetchingMore = false
    var hasMoreStories = true
    var fetchingContext: ASBatchContext?

    init(_ story: Story) {
        self.story = story
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = story.title
        store.subscribe(self) { subscription in
            subscription.select { state in state.selectedStory! }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if case .none = parent {
            store.dispatch(StoryListAction.dismiss(story))
        }
    }

    func newState(state: StoryDetails) {
        let wasFetchingMore = fetchingMore
        let oldComments = comments
        story = state.story
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

extension StoryDetailViewController: ASTableDataSource, ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return hasMoreStories
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
            let node = ASTextCellNode()
            node.text = "\(comment.author)\n\(comment.text)"
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
