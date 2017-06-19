import UIKit
import AsyncDisplayKit
import ReSwift

final class StoryDetailViewController: ASViewController<ASDisplayNode>, StoreSubscriber {
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }

    var story: Story

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

    func newState(state: Story) {
        print("StoryDetailViewController.state: \(state)")
        story = state
    }
}

extension StoryDetailViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let title = story.title
        return {
            let node = ASTextCellNode()
            node.text = title
            return node
        }
    }

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
