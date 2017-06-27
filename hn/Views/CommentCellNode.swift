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
        let author = item.deleted ? .some("deleted") : item.by
        let time = item.time.map { Date(timeIntervalSince1970: TimeInterval($0)).relative(to: Date()) }
        let info = [author, time].flatMap { $0 }.joined(separator: " ")

        text.attributedText = formatted(comment: item.text)
        details.attributedText = NSAttributedString(
            string: info,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
    }

    private func formatted(comment: String?) -> NSAttributedString {
        let font = UIFont.preferredFont(forTextStyle: .body)
        guard let comment = comment else {
            return NSAttributedString(string: "", attributes: [NSFontAttributeName: font])
        }

        let (plainText, formattingPoints) = comment.strippingHtmlElements()
        let formatted = NSMutableAttributedString(
            string: plainText,
            attributes: [NSFontAttributeName: font])
        for (type, range) in formattingPoints {
            switch type {
            case .bold:
                if let bold = font.boldVariant {
                    formatted.addAttributes(
                        [NSFontAttributeName: bold],
                        range: plainText.nsRange(from: range))
                }
            case .italic:
                if let italic = font.italicVariant {
                    formatted.addAttributes(
                        [NSFontAttributeName: italic],
                        range: plainText.nsRange(from: range))
                }
            case .code:
                if let monospace = font.monospaceVariant {
                    formatted.addAttributes(
                        [NSFontAttributeName: monospace],
                        range: plainText.nsRange(from: range))
                }
            case .url:
                formatted.addAttributes(
                    [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue],
                    range: plainText.nsRange(from: range))
            default:
                break
            }
        }
        return formatted
    }
}
