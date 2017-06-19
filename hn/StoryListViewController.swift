import UIKit
import AsyncDisplayKit
import ReSwift

final class StoryListViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, StoreSubscriber {
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }

    let storyType: StoryType
    var fetchingMore = false
    var hasMoreStories = true
    var stories = [Story]()
    var fetchingContext: ASBatchContext?

    init(_ storyType: StoryType) {
        self.storyType = storyType
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.title = storyType.description
        tableNode.leadingScreensForBatching = 1
        store.subscribe(self) { subscription in
            subscription.select { state in (state.tabs[self.storyType]!, state.selectedStory) }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
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

        let story = stories[indexPath.row]
        return {
            let node = ASTextCellNode()
            node.text = story.title
            return node
        }
    }

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return fetchingMore ? stories.count + 1 : stories.count
    }

    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return hasMoreStories
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.fetchingContext = context
        store.dispatch(fetchStories(storyType))
    }

    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        let story = stories[indexPath.row]
        store.dispatch(routeTo(story, from: self))
    }

    func newState(state: (StoryList, Story?)) {
        let (state, selectedStory) = state
        let wasFetchingMore = fetchingMore
        let oldStories = stories
        fetchingMore = state.fetchingMore
        stories = state.stories
        hasMoreStories = state.ids.count == 0 || state.stories.count < state.ids.count

        tableNode.performBatchUpdates({
            let rowCountChange = stories.count - oldStories.count
            if rowCountChange > 0 {
                let indexPaths = (oldStories.count..<stories.count).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableNode.insertRows(at: indexPaths, with: .none)
            }

            if fetchingMore != wasFetchingMore {
                if fetchingMore {
                    tableNode.insertRows(
                        at: [IndexPath(row: state.stories.count, section: 0)],
                        with: .none)
                } else {
                    tableNode.deleteRows(
                        at: [IndexPath(row: oldStories.count, section: 0)],
                        with: .none)
                    fetchingContext?.completeBatchFetching(true)
                }
            }
        }, completion: nil)

        if
            case .none = selectedStory,
            let selectedRow = tableNode.indexPathForSelectedRow
        {
            tableNode.deselectRow(at: selectedRow, animated: true)
        }
    }
}
