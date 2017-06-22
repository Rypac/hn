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

    func update(comment: String, author: String, timestamp: Int) {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let timeSincePosting = date.relative(to: Date())
        text.attributedText = NSAttributedString(
            string: comment,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        details.attributedText = NSAttributedString(
            string: "\(author) \(timeSincePosting)",
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
    }
}
