import Foundation

enum FormattingOption {
    case paragraph
    case url
    case italic
    case bold
    case code
    case preformatted
}

enum Tag {
    case open(FormattingOption?)
    case close(FormattingOption?)
}

private let htmlTags: [String: FormattingOption] = [
    "p": .paragraph,
    "i": .italic,
    "b": .bold,
    "a": .url,
    "pre": .preformatted,
    "code": .code
]

private let entityEncodings: [String: Character] = [
    "quot": "\"",
    "apos": "'",
    "amp": "&",
    "lt": "<",
    "gt": ">"
]

extension String {
    typealias FormattingPoints = [(FormattingOption, Range<Index>)]

    func strippingHtmlElements() -> (String, FormattingPoints) {
        var result = ""
        var points = [(FormattingOption, Range<Index>)]()

        var position = startIndex
        var tags = [FormattingOption: [Range<Index>]]()

        parser: while position < endIndex {
            let character = self[position]
            switch character {
            case "<":
                if let (tag, range) = parseTagStart(after: position) {
                    switch tag {
                    case let .open(.some(innerTag)):
                        if innerTag == .paragraph {
                            let tagStart = result.endIndex
                            result.append("\n\n")
                            points.append((innerTag, tagStart..<result.endIndex))
                        } else {
                            let tagRange = result.endIndex..<result.endIndex
                            var stack = tags[innerTag] ?? []
                            stack.append(tagRange)
                            tags[innerTag] = stack
                        }
                    case let .close(.some(innerTag)):
                        if let parsed = tags[innerTag]?.popLast() {
                            let tagStart = parsed.lowerBound
                            points.append((innerTag, tagStart..<result.endIndex))
                        }
                    default:
                        break
                    }
                    position = index(after: range.upperBound)
                } else {
                    break parser
                }
            case "&":
                let start = index(after: position)
                if start < endIndex, let end = range(of: ";", range: start..<endIndex) {
                    let encoded = self[start..<end.lowerBound]
                    if let decoded = encoded.decode() {
                        result.append(decoded)
                    } else {
                        result.append(self[position..<end.upperBound])
                    }
                    position = end.upperBound
                } else {
                    break parser
                }
            default:
                result.append(character)
                position = index(after: position)
            }
        }

        if position < endIndex {
            result.append(self[position..<endIndex])
        }
        return (result, points)
    }

    private func parseTagStart(after tagStart: Index) -> (Tag, Range<Index>)? {
        let next = index(after: tagStart)
        guard next < endIndex else {
            return .none
        }

        switch self[next] {
        case " ":
            return parseTagStart(after: next)
        case "/":
            let closeTag = index(after: next)
            guard closeTag < endIndex else {
                return .none
            }
            if let (option, end) = parseInnerTag(from: closeTag) {
                return (.close(option), tagStart..<end)
            } else {
                return .none
            }
        default:
            if let (option, end) = parseInnerTag(from: next) {
                return (.open(option), tagStart..<end)
            } else {
                return .none
            }
        }
    }

    private func parseInnerTag(from start: Index) -> (FormattingOption?, Index)? {
        let next = index(after: start)
        guard let close = range(of: ">", range: next..<endIndex)?.lowerBound else {
            return .none
        }

        let end = range(of: " ", range: next..<close)?.lowerBound ?? close
        let tag = self[start..<end]
        return (htmlTags[tag], close)
    }

    private func decode() -> Character? {
        guard hasPrefix("#") else {
            return entityEncodings[self]
        }

        let offset = index(after: startIndex)
        let encoded = self[offset..<endIndex]
        return encoded.hasPrefix("x") || encoded.hasPrefix("X")
            ? encoded[index(after: encoded.startIndex)..<encoded.endIndex].decode(base: 16)
            : encoded.decode(base: 10)
    }

    private func decode(base: Int) -> Character? {
        guard
            let code = UInt32(self, radix: base),
            let unicode = UnicodeScalar(code)
        else {
            return .none
        }
        return Character(unicode)
    }
}
