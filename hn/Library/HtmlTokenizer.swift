import Foundation

enum HtmlTag: String {
    case p, a, b, i, u, br, pre, code
}

typealias HtmlAttributes = [String]

enum HtmlToken: Token {
    case open(HtmlTag, HtmlAttributes)
    case close(HtmlTag)
    case entity(UnicodeScalar)
    case text(UnicodeScalar)
}

enum HtmlTokenError: Error {
    case unknownTag
    case invalidTag
    case invalidEntity
}

struct HtmlTokenizer: Tokenizer {
    typealias Value = HtmlToken
    typealias Error = HtmlTokenError

    private var iterator: String.UnicodeScalarView.Iterator
    private var pushedBackScalar: UnicodeScalar?

    init(text: String) {
        iterator = text.unicodeScalars.makeIterator()
    }

    mutating func nextToken() -> TokenResult<Value, Error>? {
        while let char = nextCharacter() {
            switch char {
            case HtmlTagId.start:
                return parseTag()
            case HtmlEntity.start:
                return parseEntity()
            default:
                return .success(.text(char))
            }
        }
        return .none
    }

    private mutating func nextCharacter() -> UnicodeScalar? {
        return iterator.next()
    }

    private mutating func parseTag() -> TokenResult<Value, Error> {
        var tag: String? = .none
        var text = String()
        var attributes = HtmlAttributes()
        var isCloseTag = false

        let pushToken = {
            guard !text.isEmpty else {
                return
            }
            if tag == .none {
                tag = text
            } else {
                attributes.append(text)
            }
            text = ""
        }

        while let char = nextCharacter() {
            switch char {
            case HtmlTagId.separator:
                pushToken()
            case HtmlTagId.close where tag == .none:
                isCloseTag = true
            case HtmlTagId.end:
                pushToken()
                guard let tag = tag.flatMap(HtmlTag.init(rawValue:)) else {
                    return .error(.unknownTag)
                }
                return .success(isCloseTag ? .close(tag) : .open(tag, attributes))
            default:
                text.unicodeScalars.append(char)
            }
        }
        return .error(.invalidTag)
    }

    private mutating func parseEntity() -> TokenResult<Value, Error> {
        var char = nextCharacter()
        guard char == HtmlEntity.number else {
            var entityName = String()
            while let ch = char, ch != HtmlEntity.end {
                entityName.unicodeScalars.append(ch)
                char = nextCharacter()
            }
            guard let entity = HtmlEntity.decode(entityName).map(HtmlToken.entity) else {
                return .error(.invalidEntity)
            }
            return .success(entity)
        }

        let radix: Int
        char = nextCharacter()
        if char == HtmlEntity.hexLower || char == HtmlEntity.hexUpper {
            radix = 16
            char = nextCharacter()
        } else {
            radix = 10
        }

        var number = String()
        while let digit = char, digit != HtmlEntity.end {
            number.unicodeScalars.append(digit)
            char = nextCharacter()
        }

        guard let entity = UInt32(number, radix: radix)
            .flatMap(UnicodeScalar.init)
            .flatMap(HtmlToken.entity)
        else {
            return .error(.invalidEntity)
        }
        return .success(entity)
    }
}

private struct HtmlTagId {
    static let start: UnicodeScalar = "<"
    static let end: UnicodeScalar = ">"
    static let close: UnicodeScalar = "/"
    static let separator: UnicodeScalar = " "
}

private struct HtmlEntity {
    static let start: UnicodeScalar = "&"
    static let end: UnicodeScalar = ";"
    static let number: UnicodeScalar = "#"
    static let hexLower: UnicodeScalar = "x"
    static let hexUpper: UnicodeScalar = "X"

    private static let quote = "quot"
    private static let apos = "apos"
    private static let amp = "amp"
    private static let lt = "lt"
    private static let gt = "gt"

    static func decode(_ entity: String) -> UnicodeScalar? {
        switch entity {
        case quote: return "\""
        case apos: return "'"
        case amp: return "&"
        case lt: return "<"
        case gt: return ">"
        default: return nil
        }
    }
}
