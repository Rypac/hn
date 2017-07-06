import AsyncDisplayKit
import UIKit

final class CommentCellNode: ASCellNode {
    let text = ASTextNode()
    let details = ASTextNode()
    let depth: CGFloat

    init(_ comment: Comment) {
        self.depth = CGFloat(comment.depth)
        super.init()
        automaticallyManagesSubnodes = true

        let (text, details) = comment.cellText()

        self.text.attributedText = text?.strippingHtmlElements().attributedText
        self.details.attributedText = NSAttributedString(
            string: details,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 8, left: 8 + 10 * depth, bottom: 8, right: 8),
            child: ASStackLayoutSpec(
                direction: .vertical,
                spacing: 4,
                flex: (shrink: 1.0, grow: 1.0),
                children: [details, text]))
    }
}

extension Comment {
     fileprivate func cellText() -> (String?, String) {
        switch content {
        case .details(let content):
            let time = Date(timeIntervalSince1970: TimeInterval(content.time)).relative(to: Date())
            return (content.text, "\(content.author) \(time)")
        case .dead:
            return (.none, "dead")
        case .deleted:
            return (.none, "deleted")
        }
    }
}
