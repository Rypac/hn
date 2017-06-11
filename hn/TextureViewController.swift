import UIKit
import AsyncDisplayKit

final class LoadingCellNode: ASCellNode {
    let spinner = SpinnerNode()
    let text = ASTextNode()

    override init() {
        super.init()
        addSubnode(text)
        text.attributedText = NSAttributedString(
            string: "Loading...",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 12),
                NSForegroundColorAttributeName: UIColor.lightGray,
                NSKernAttributeName: -0.3
            ])
        addSubnode(spinner)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 16,
            justifyContent: .center,
            alignItems: .center,
            children: [text, spinner])
    }
}

final class SpinnerNode: ASDisplayNode {
    var activityIndicatorView: UIActivityIndicatorView {
        return view as! UIActivityIndicatorView
    }

    override init() {
        super.init()
        setViewBlock {
            UIActivityIndicatorView(activityIndicatorStyle: .gray)
        }
        self.style.preferredSize = CGSize(width: 20.0, height: 20.0)
    }
    
    override func didLoad() {
        super.didLoad()
        activityIndicatorView.startAnimating()
    }
}

final class TextureViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {
    struct State {
        var stories: [Story]
        var fetchingMore: Bool
        static let empty = State(stories: [], fetchingMore: false)
    }

    enum Action {
        case beginBatchFetch
        case endBatchFetch(stories: [Story])
    }

    var tableNode: ASTableNode {
        return node as! ASTableNode
    }

    fileprivate(set) var state: State = .empty

    init() {
        super.init(node: ASTableNode())
        tableNode.delegate = self
        tableNode.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        // Should read the row count directly from table view but
        // https://github.com/facebook/AsyncDisplayKit/issues/1159
        let rowCount = self.tableNode(tableNode, numberOfRowsInSection: 0)

        if state.fetchingMore && indexPath.row == rowCount - 1 {
            let node = LoadingCellNode()
            node.style.height = ASDimensionMake(44.0)
            return node;
        }

        let node = ASTextCellNode()
        let story = state.stories[indexPath.row]
        node.text = story.title
        return node
    }

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 1
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return state.fetchingMore ? state.stories.count + 1 : state.stories.count
    }

    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        DispatchQueue.main.async {
            let oldState = self.state
            self.state = TextureViewController.handleAction(.beginBatchFetch, fromState: oldState)
            self.renderDiff(oldState)
        }

        TextureViewController.fetchTopStories { stories in
            let oldState = self.state
            let action = Action.endBatchFetch(stories: stories)
            self.state = TextureViewController.handleAction(action, fromState: oldState)
            self.renderDiff(oldState)
            context.completeBatchFetching(true)
        }
    }

    fileprivate func renderDiff(_ oldState: State) {
        self.tableNode.performBatchUpdates({
            // Add or remove items
            let rowCountChange = state.stories.count - oldState.stories.count
            if rowCountChange > 0 {
                let indexPaths = (oldState.stories.count..<state.stories.count).map { index in
                    IndexPath(row: index, section: 0)
                }
                tableNode.insertRows(at: indexPaths, with: .none)
            } else if rowCountChange < 0 {
                assertionFailure("Deleting rows is not implemented. YAGNI.")
            }

            // Add or remove spinner.
            if state.fetchingMore != oldState.fetchingMore {
                if state.fetchingMore {
                    let spinnerIndex = IndexPath(row: state.stories.count, section: 0)
                    tableNode.insertRows(at: [spinnerIndex], with: .none)
                } else {
                    let spinnerIndex = IndexPath(row: oldState.stories.count, section: 0)
                    tableNode.deleteRows(at: [spinnerIndex], with: .none)
                }
            }
        }, completion:nil)
    }

    fileprivate static func handleAction(_ action: Action, fromState state: State) -> State {
        var state = state
        switch action {
        case .beginBatchFetch:
            state.fetchingMore = true
        case let .endBatchFetch(stories):
            state.stories += stories
            state.fetchingMore = false
        }
        return state
    }

    fileprivate static func fetchTopStories(_ completion: @escaping ([Story]) -> Void) {
        var stories = [Story]()
        fetch(.topStories) { (ids: [Int]) in
            ids.prefix(upTo: 20).forEach {
                fetch(.item($0)) { (story: Story) in
                    DispatchQueue.main.async {
                        stories.append(story)
                        if stories.count == 20 {
                            completion(stories)
                        }
                    }
                }
            }
        }
    }
}
