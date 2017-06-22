import UIKit
import AsyncDisplayKit

final class ItemCellNode: ASCellNode {
    let text = ASTextNode()
    let details = ASTextNode()
    let comments = ASTextNode()

    override init() {
        super.init()
        addSubnode(text)
        addSubnode(details)
        addSubnode(comments)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let textStack = ASStackLayoutSpec.vertical()
        textStack.spacing = 4
        textStack.style.flexShrink = 1.0
        textStack.style.flexGrow = 1.0
        textStack.children = [text, details]

        let cellStack = ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 20,
            justifyContent: .start,
            alignItems: .center,
            children: [textStack, comments])

        return ASInsetLayoutSpec(insets: UIEdgeInsets(horizontal: 8, vertical: 4), child: cellStack)
    }

    func update(title: String, author: String, comments: Int, score: Int, time: Int) {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let timeSincePosting = date.relative(to: Date())
        text.attributedText = NSAttributedString(
            string: title,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        details.attributedText = NSAttributedString(
            string: "\(score) points by \(author) \(timeSincePosting)",
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
        self.comments.attributedText = NSAttributedString(
            string: "\(comments)",
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
    }
}
