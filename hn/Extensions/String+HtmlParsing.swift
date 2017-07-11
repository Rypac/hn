// swiftlint:disable cyclomatic_complexity function_body_length
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
    func strippingHtmlElements() -> FormattedString {
        let newline: UnicodeScalar = "\n"

        var result = ""
        var points = [(Formatting, Range<Index>)]()
        var tags = [HtmlTag: [Range<Index>]]()

        func push(_ tag: HtmlTag) {
            let tagRange = result.endIndex..<result.endIndex
            var stack = tags[tag] ?? []
            stack.append(tagRange)
            tags[tag] = stack
        }

        func pop(_ tag: HtmlTag) {
            if let parsed = tags[tag]?.popLast(), let formatting = Formatting(from: tag) {
                let tagStart = parsed.lowerBound
                points.append((formatting, tagStart..<result.endIndex))
            }
        }

        var dealtWithOpeningTag = false
        func handleOpenParagraphTag() {
            if let lastTag = tags[.p]?.popLast() {
                let openTagEnd = result.endIndex
                result.unicodeScalars.append(newline)
                result.unicodeScalars.append(newline)
                points.append((.paragraph, lastTag.upperBound..<openTagEnd))
            } else if !dealtWithOpeningTag {
                if !result.isEmpty {
                    let openTagEnd = result.endIndex
                    result.unicodeScalars.append(newline)
                    result.unicodeScalars.append(newline)
                    points.append((.paragraph, result.startIndex..<openTagEnd))
                }
                dealtWithOpeningTag = true
            } else {
                result.unicodeScalars.append(newline)
                result.unicodeScalars.append(newline)
            }
        }

        var tokenizer = HtmlTokenizer(text: self)

        while let token = tokenizer.nextToken() {
            switch token {
            case let .success(tag):
                switch tag {
                case let .open(tag, _):
                    switch tag {
                    case .p:
                        handleOpenParagraphTag()
                        push(tag)
                    case .br:
                        let tagEnd = result.endIndex
                        result.unicodeScalars.append(newline)
                        points.append((.linebreak, result.startIndex..<tagEnd))
                    default:
                        push(tag)
                    }
                case let .close(tag):
                    pop(tag)
                case let .entity(char), let .text(char):
                    result.unicodeScalars.append(char)
                }
            case let .error(error) where error != .unknownTag:
                return FormattedString(text: self, formatting: [])
            default:
                break
            }
        }

        if let unbalancedParagraphTag = tags[.p]?.popLast() {
            points.append((.paragraph, unbalancedParagraphTag.upperBound..<result.endIndex))
        }

        return FormattedString(text: result, formatting: points)
    }
}
