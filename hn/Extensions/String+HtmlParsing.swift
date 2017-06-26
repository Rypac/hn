import Foundation

enum FormattingOption {
    case paragraph
    case url
    case italic
    case bold
    case code
}

enum Tag {
    case open(FormattingOption?)
    case close(FormattingOption?)
}

private let tagTable: [Character: FormattingOption] = [
    "p": .paragraph,
    "i": .italic,
    "b": .bold,
    "a": .url
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

    private func parseInnerTag(from tagStart: Index) -> (FormattingOption?, Index)? {
        guard let close = parseTagEnd(after: tagStart) else {
            return .none
        }

        let tag = self[tagStart]
        return (tagTable[tag], close)
    }

    private func parseTagEnd(after tagStart: Index) -> Index? {
        var next = index(after: tagStart)
        while next < endIndex {
            if self[next] == ">" {
                return next
            }
            next = index(after: next)
        }
        return .none
    }
}
