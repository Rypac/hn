import AsyncDisplayKit
import UIKit

final class CommentCellNode: ASCellNode {
    let text = ASTextNode()
    let details = ASTextNode()
    let depth: CGFloat

    init(_ comment: Comment) {
        depth = CGFloat(comment.depth)
        super.init()
        automaticallyManagesSubnodes = true

        let item = comment.item
        let author = item.deleted ? .some("deleted") : item.author
        let time = item.time.map { Date(timeIntervalSince1970: TimeInterval($0)).relative(to: Date()) }
        let info = [author, time].flatMap { $0 }.joined(separator: " ")

        text.attributedText = item.text?.strippingHtmlElements().attributedText
        details.attributedText = NSAttributedString(
            string: info,
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
