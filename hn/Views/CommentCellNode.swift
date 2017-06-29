import UIKit
import AsyncDisplayKit

final class CommentCellNode: ASCellNode {
    let text = ASTextNode()
    let details = ASTextNode()
    let depth: CGFloat

    init(_ comment: CommentItem) {
        depth = CGFloat(comment.depth)

        super.init()
        automaticallyManagesSubnodes = true

        let item = comment.item
        let author = item.deleted ? .some("deleted") : item.author
        let time = item.time.map { Date(timeIntervalSince1970: TimeInterval($0)).relative(to: Date()) }
        let info = [author, time].flatMap { $0 }.joined(separator: " ")

        text.attributedText = item.text?.formatted()
        details.attributedText = NSAttributedString(
            string: info,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 8, left: 10 * depth, bottom: 8, right: 8),
            child: ASStackLayoutSpec(
                direction: .vertical,
                spacing: 4,
                flex: (shrink: 1.0, grow: 1.0),
                children: [details, text]))
    }
}

extension String {
    internal func formatted() -> NSAttributedString {
        let (text, formattingPoints) = strippingHtmlElements()

        let font = UIFont.preferredFont(forTextStyle: .body)
        let formatted = NSMutableAttributedString(
            string: text,
            attributes: [NSFontAttributeName: font])

        for (type, range) in formattingPoints {
            switch type {
            case .bold:
                if let bold = font.boldVariant {
                    formatted.addAttributes(
                        [NSFontAttributeName: bold],
                        range: text.nsRange(from: range))
                }
            case .italic:
                if let italic = font.italicVariant {
                    formatted.addAttributes(
                        [NSFontAttributeName: italic],
                        range: text.nsRange(from: range))
                }
            case .code:
                if let monospace = font.monospaceVariant {
                    formatted.addAttributes(
                        [NSFontAttributeName: monospace],
                        range: text.nsRange(from: range))
                }
            case .url:
                formatted.addAttributes(
                    [NSLinkAttributeName: text[range]],
                    range: text.nsRange(from: range))
            default:
                break
            }
        }
        return formatted
    }
}
