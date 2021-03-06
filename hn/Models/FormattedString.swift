import UIKit

let kFormattingAttributes = "FormattingAttributes"

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
    fileprivate let attributes: [String]

    init(_ attributes: [String] = []) {
        self.attributes = attributes
    }

    func find(_ attribute: String) -> String? {
        return attributes.lazy
            .flatMap { $0.slice(from: "\(attribute)=\"", to: "\"") }
            .first?
            .decodingHtmlEntities()
    }
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
                formatted.addAttributes(
                    [
                        kFormattingAttributes: option.attributes,
                        NSForegroundColorAttributeName: UIColor.Apple.blue
                    ],
                    range: nsRange)
            default:
                break
            }
        }
        return formatted
    }
}

// MARK: - Equatable

extension FormattedString: Equatable {
    static func == (_ lhs: FormattedString, _ rhs: FormattedString) -> Bool {
        return lhs.text == rhs.text && lhs.formatting == rhs.formatting
    }
}

extension FormattingOptions: Equatable {
    static func == (_ lhs: FormattingOptions, _ rhs: FormattingOptions) -> Bool {
        return lhs.type == rhs.type &&
            lhs.range == rhs.range &&
            lhs.attributes == rhs.attributes
    }
}

extension Attributes: Equatable {
    static func == (_ lhs: Attributes, _ rhs: Attributes) -> Bool {
        return lhs.attributes == rhs.attributes
    }
}
