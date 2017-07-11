import UIKit

struct FormattedString {
    let text: String
    let formatting: [FormattingOptions]
}

struct FormattingOptions {
    let type: Formatting
    let attributes: Attributes
    let range: Range<String.Index>

    init(_ type: Formatting, range: Range<String.Index>, attributes: Attributes = Attributes()) {
        self.type = type
        self.range = range
        self.attributes = attributes
    }
}

struct Attributes {
    private let attributes: [String]

    init(_ attributes: [String] = []) {
        self.attributes = attributes
    }

    func find(_ attribute: String) -> String? {
        return attributes.lazy.flatMap { $0.slice(from: "\(attribute)=\"", to: "\"") }.first
    }
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

        for option in formatting {
            let nsRange = text.nsRange(from: option.range)
            switch option.type {
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
