import UIKit
import AsyncDisplayKit

final class CommentCellNode: ASCellNode {
    let text = ASTextNode()
    let details = ASTextNode()

    override init() {
        super.init()
        addSubnode(text)
        addSubnode(details)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let cellStack = ASStackLayoutSpec.vertical()
        cellStack.spacing = 4
        cellStack.style.flexShrink = 1.0
        cellStack.style.flexGrow = 1.0
        cellStack.children = [details, text]

        return ASInsetLayoutSpec(insets: UIEdgeInsets(horizontal: 8, vertical: 4), child: cellStack)
    }
}

extension CommentCellNode {
    convenience init(_ item: Item) {
        self.init()
        let comment = item.text ?? ""
        let author = item.deleted ? .some("deleted") : item.by
        let time = item.time.map { Date(timeIntervalSince1970: TimeInterval($0)).relative(to: Date()) }
        let info = [author, time].flatMap { $0 }.joined(separator: " ")

        text.attributedText = NSAttributedString(
            string: comment,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        details.attributedText = NSAttributedString(
            string: info,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
    }
}
