import Foundation

enum HtmlTokenError: Error {
    case invalidTag
}

typealias HtmlAttributes = [String]

enum HtmlToken: Token {
    case open(HtmlTag?, HtmlAttributes)
    case close(HtmlTag?)
    case text(Character)
}

enum HtmlTag: String {
    case p, a, b, i, pre, code
}

private struct HtmlTagId {
    static let start: UnicodeScalar = "<"
    static let end: UnicodeScalar = ">"
    static let close: UnicodeScalar = "/"
    static let separator: UnicodeScalar = " "
}

private struct HtmlEntityId {
    static let start: UnicodeScalar = "&"
    static let end: UnicodeScalar = ";"
    static let number: UnicodeScalar = "#"
    static let hexLower: UnicodeScalar = "x"
    static let hexUpper: UnicodeScalar = "X"
    static let encodings: [String: Character] = [
        "quot": "\"",
        "apos": "'",
        "amp": "&",
        "lt": "<",
        "gt": ">"
    ]
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
        while let ch = nextCharacter() {
            switch ch {
            case HtmlTagId.start:
                return run(parseTag())
            case HtmlEntityId.start:
                return run(parseEntity())
            default:
                return run(.text(Character(ch)))
            }
        }
        return .none
    }

    private mutating func run(_ parser: @autoclosure () -> HtmlToken?) -> TokenResult<Value, Error> {
        guard let result = parser() else {
            return .error(HtmlTokenError.invalidTag)
        }
        return .success(result)
    }

    private mutating func nextCharacter() -> UnicodeScalar? {
        guard let char = iterator.next() else {
            return .none
        }
        return char
    }

    private mutating func parseTag() -> HtmlToken? {
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
                guard let tag = tag else {
                    return .none
                }
                let token = HtmlTag(rawValue: tag)
                return isCloseTag ? .close(token) : .open(token, attributes)
            default:
                text.unicodeScalars.append(char)
            }
        }
        return .none
    }

    private mutating func parseEntity() -> HtmlToken? {
        var char = nextCharacter()
        guard char == HtmlEntityId.number else {
            var entityName = String()
            while let letter = char, letter != HtmlEntityId.end {
                entityName.unicodeScalars.append(letter)
                char = nextCharacter()
            }
            return HtmlEntityId.encodings[entityName].map(HtmlToken.text)
        }

        let radix: Int
        char = nextCharacter()
        if char == HtmlEntityId.hexLower || char == HtmlEntityId.hexUpper {
            radix = 16
            char = nextCharacter()
        } else {
            radix = 10
        }

        var number = String()
        while let digit = char, digit != HtmlEntityId.end {
            number.unicodeScalars.append(digit)
            char = nextCharacter()
        }
        return UInt32(number, radix: radix)
            .flatMap(UnicodeScalar.init)
            .flatMap(Character.init)
            .flatMap(HtmlToken.text)
    }
}
