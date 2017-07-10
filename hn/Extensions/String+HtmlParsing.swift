// swiftlint:disable cyclomatic_complexity function_body_length
import Foundation

enum Tag {
    case open(Formatting?)
    case close(Formatting?)
}

private let htmlTags: [String: Formatting] = [
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
    func strippingHtmlElements() -> FormattedString {
        var result = ""
        var points = [(Formatting, Range<Index>)]()

        var position = startIndex
        var balancedStartParagraphTag = false
        var tags = [Formatting: [Range<Index>]]()

        func push(tag: Formatting) {
            let tagRange = result.endIndex..<result.endIndex
            var stack = tags[tag] ?? []
            stack.append(tagRange)
            tags[tag] = stack
        }

        func pop(tag: Formatting) {
            if let parsed = tags[tag]?.popLast() {
                let tagStart = parsed.lowerBound
                points.append((tag, tagStart..<result.endIndex))
            }
        }

        parser: while position < endIndex {
            let character = self[position]
            switch character {
            case "<":
                guard let (tag, range) = parseTag(after: position) else {
                    break parser
                }

                switch tag {
                case let .open(innerTag?):
                    if innerTag == .paragraph {
                        if range.lowerBound == startIndex {
                            balancedStartParagraphTag = true
                        } else if let lastTag = tags[innerTag]?.last {
                            let openTagEnd = result.endIndex
                            result.append("\n\n")
                            points.append((innerTag, lastTag.upperBound..<openTagEnd))
                        } else if !balancedStartParagraphTag {
                            let openTagEnd = result.endIndex
                            result.append("\n\n")
                            points.append((innerTag, result.startIndex..<openTagEnd))
                        }
                    }
                    push(tag: innerTag)
                case let .close(innerTag?):
                    pop(tag: innerTag)
                    if innerTag == .paragraph && range.upperBound < index(before: endIndex) {
                        result.append("\n\n")
                    }
                default:
                    break
                }
                position = index(after: range.upperBound)
            case "&":
                let start = index(after: position)
                guard let end = range(of: ";", range: start..<endIndex) else {
                    break parser
                }

                let encoded = self[start..<end.lowerBound]
                if let decoded = encoded.decode() {
                    result.append(decoded)
                } else {
                    result.append(self[position..<end.upperBound])
                }
                position = end.upperBound
            default:
                result.append(character)
                position = index(after: position)
            }
        }

        if position < endIndex {
            result.append(self[position..<endIndex])
        }
        if let unbalancedFinalTag = tags[.paragraph]?.last {
            points.append((.paragraph, unbalancedFinalTag.upperBound..<result.endIndex))
        }

        return FormattedString(text: result, formatting: points)
    }

    private func parseTag(after tagStart: Index) -> (Tag, Range<Index>)? {
        let next = index(after: tagStart)
        guard next < endIndex else {
            return .none
        }

        switch self[next] {
        case " ":
            return parseTag(after: next)
        case "/":
            let closeTag = index(after: next)
            guard closeTag < endIndex else {
                return .none
            }
            return parseInnerTag(from: closeTag).map { tag, end in (.close(tag), tagStart..<end) }
        default:
            return parseInnerTag(from: next).map { tag, end in (.open(tag), tagStart..<end) }
        }
    }

    private func parseInnerTag(from start: Index) -> (Formatting?, Index)? {
        guard let close = range(of: ">", range: start..<endIndex)?.lowerBound else {
            return .none
        }

        let end = range(of: " ", range: start..<close)?.lowerBound ?? close
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
        return UInt32(self, radix: base)
            .flatMap(UnicodeScalar.init)
            .flatMap(Character.init)
    }
}
