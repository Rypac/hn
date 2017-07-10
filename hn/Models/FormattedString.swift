import UIKit

struct FormattedString {
    let text: String
    let formatting: [(Formatting, Range<String.Index>)]
}

enum Formatting {
    case paragraph
    case url
    case italic
    case bold
    case underline
    case code
    case preformatted
    case linebreak
}

extension FormattedString {
    func attributedText(withFont font: UIFont) -> NSAttributedString {
        let formatted = NSMutableAttributedString(
            string: text,
            attributes: [NSFontAttributeName: font])

        for (type, range) in formatting {
            let nsRange = text.nsRange(from: range)
            switch type {
            case .bold:
                if let bold = font.boldVariant {
                    formatted.addAttributes([NSFontAttributeName: bold], range: nsRange)
                }
            case .italic:
                if let italic = font.italicVariant {
                    formatted.addAttributes([NSFontAttributeName: italic], range: nsRange)
                }
            case .underline:
                formatted.addAttributes(
                    [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue],
                    range: nsRange)
            case .code:
                formatted.addAttributes([NSFontAttributeName: Font.menlo.body], range: nsRange)
            case .url:
                formatted.addAttributes([NSLinkAttributeName: text], range: nsRange)
            default:
                break
            }
        }
        return formatted
    }
}
