// swiftlint:disable function_body_length
import Foundation

enum Tag {
    case open(Formatting?)
    case close(Formatting?)
}

extension HtmlTag {
    var formatting: Formatting {
        switch self {
        case .a: return .url
        case .b: return .bold
        case .i: return .italic
        case .p: return .paragraph
        case .pre: return .preformatted
        case .code: return .code
        }
    }
}

extension String {
    func strippingHtmlElements() -> FormattedString {
        var result = ""
        var points = [(Formatting, Range<Index>)]()
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

        var startedWithOpenParagraphTag = false
        func handleOpenParagraphTag() {
            if result.isEmpty {
                startedWithOpenParagraphTag = true
            } else if let lastTag = tags[.paragraph]?.popLast() {
                let openTagEnd = result.endIndex
                result.append("\n\n")
                points.append((.paragraph, lastTag.upperBound..<openTagEnd))
            } else if !startedWithOpenParagraphTag {
                startedWithOpenParagraphTag = true
                let openTagEnd = result.endIndex
                result.append("\n\n")
                points.append((.paragraph, result.startIndex..<openTagEnd))
            } else {
                result.append("\n\n")
            }
        }

        var tokenizer = HtmlTokenizer(text: self)

        parser: while let token = tokenizer.nextToken() {
            switch token {
            case let .success(tag):
                switch tag {
                case let .open(tag?, _):
                    if tag == .p {
                        handleOpenParagraphTag()
                    }
                    push(tag: tag.formatting)
                case let .close(tag?):
                    pop(tag: tag.formatting)
                case let .text(char):
                    result.append(char)
                default:
                    break
                }
            case let .error(error):
                print(error)
                break parser
            }
        }

        if let unbalancedFinalTag = tags[.paragraph]?.popLast() {
            points.append((.paragraph, unbalancedFinalTag.upperBound..<result.endIndex))
        }

        return FormattedString(text: result, formatting: points)
    }
}
