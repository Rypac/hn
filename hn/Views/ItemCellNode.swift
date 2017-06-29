import UIKit
import AsyncDisplayKit

final class ItemCellNode: ASCellNode {
    let text = ASTextNode()
    let details = ASTextNode()
    let comments = ASTextNode()

    init(_ item: Item) {
        super.init()
        automaticallyManagesSubnodes = true

        guard
            let title = item.title,
            let score = item.score,
            let author = item.author,
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

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(horizontal: 8, vertical: 6),
            child: ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 20,
                justifyContent: .start,
                alignItems: .center,
                children: [
                    ASStackLayoutSpec(
                        direction: .vertical,
                        spacing: 4,
                        flex: (shrink: 1.0, grow: 1.0),
                        children: [text, details]),
                    comments
                ]))
    }
}
