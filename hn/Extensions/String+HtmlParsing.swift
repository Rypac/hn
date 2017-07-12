import Foundation

extension Formatting {
    init?(from tag: HtmlTag) {
        switch tag {
        case .a: self = .url
        case .b: self = .bold
        case .i: self = .italic
        case .u: self = .underline
        case .p: self = .paragraph
        case .pre: self = .preformatted
        case .code: self = .code
        case .br: self = .linebreak
        }
    }
}

extension String {
    func decodingHtmlEntities() -> String {
        var result = String()
        result.reserveCapacity(utf8.count)

        var tokenizer = HtmlTokenizer(text: self)

        while let token = tokenizer.nextToken() {
            switch token {
            case let .success(.entity(char)), let .success(.text(char)):
                result.unicodeScalars.append(char)
            case let .error(error) where error != .unknownTag:
                return self
            default:
                break
            }
        }

        return result
    }

    func strippingHtmlElements() -> FormattedString {
        return HtmlParser.parse(self) ?? FormattedString(text: self, formatting: [])
    }
}
