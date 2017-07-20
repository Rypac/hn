import AsyncDisplayKit

protocol ItemDetailsDataProvider: DataProvider {
    var parent: Post { get }
    var comments: [CommentViewModel] { get }
}

final class ItemDetailsDataSource: NSObject, DataSource, ASTableDataSource {
    typealias Provider = ItemDetailsDataProvider

    enum Section: Int {
        case parent = 0
        case comments = 1
    }

    var provider: Provider {
        didSet {
            diff = ListDiffPaths(
                fromSection: 1,
                toSection: 1,
                oldArray: oldValue.comments,
                newArray: provider.comments,
                option: .equality)
        }
    }

    private(set) var diff: ListIndexPathResult?

    weak var delegate: ASTextNodeDelegate?

    init(_ provider: Provider) {
        self.provider = provider
    }

    func numberOfSections(in tableNode: ASTableNode) -> Int {
        return 2
    }

    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return section == Section.comments.rawValue
            ? provider.comments.count
            : 1
    }

    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        if indexPath.as(Section.self) == .parent {
            let parent = provider.parent
            return {
                let node = PostHeaderCellNode(viewModel: parent)
                node.selectionStyle = .none
                return node
            }
        }

        let comment = provider.comments[indexPath.row]
        let delegate = self.delegate
        return {
            let node = CommentCellNode(viewModel: comment)
            node.selectionStyle = .none
            node.text.delegate = delegate
            node.text.isUserInteractionEnabled = true
            return node
        }
    }
}
