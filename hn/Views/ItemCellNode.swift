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
}

extension ItemCellNode {
    convenience init(_ item: Item) {
        self.init()
        guard
            let title = item.title,
            let score = item.score,
            let author = item.by,
            let timestamp = item.time
        else {
            return
        }

        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let timeSincePosting = date.relative(to: Date())
        text.attributedText = NSAttributedString(
            string: title,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        details.attributedText = NSAttributedString(
            string: "\(score) points by \(author) \(timeSincePosting)",
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
        if let descendants = item.descendants {
            comments.attributedText = NSAttributedString(
                string: "\(descendants)",
                attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        }
    }
}
