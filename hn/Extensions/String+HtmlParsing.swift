// swiftlint:disable cyclomatic_complexity function_body_length
import Foundation

extension Sequence where Iterator.Element == String {
    func extract(attribute: String) -> String? {
        return lazy.flatMap { $0.slice(from: "\(attribute)=\"", to: "\"") }.first
    }
}

extension Formatting {
    init?(from tag: HtmlTag, attributes: HtmlAttributes) {
        switch tag {
        case .a: self = .url(attributes.extract(attribute: "href")?.decodingHtmlEntities())
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
        let newline: UnicodeScalar = "\n"

        var result = String()
        result.reserveCapacity(utf8.count)

        var points = [(Formatting, Range<Index>)]()
        var tags = [HtmlTag: [(HtmlAttributes, Range<Index>)]]()

        func push(_ tag: HtmlTag, _ attributes: HtmlAttributes) {
            let tagRange = result.endIndex..<result.endIndex
            var stack = tags[tag] ?? []
            stack.append(attributes, tagRange)
            tags[tag] = stack
        }

        func pop(_ tag: HtmlTag) {
            if let parsed = tags[tag]?.popLast(), let formatting = Formatting(from: tag, attributes: parsed.0) {
                let tagStart = parsed.1.lowerBound
                points.append((formatting, tagStart..<result.endIndex))
            }
        }

        var dealtWithOpeningTag = false
        func handleOpenParagraphTag() {
            if let (_, lastTag) = tags[.p]?.popLast() {
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
                case let .open(tag, attributes):
                    switch tag {
                    case .p:
                        handleOpenParagraphTag()
                        push(tag, attributes)
                    case .br:
                        let tagEnd = result.endIndex
                        result.unicodeScalars.append(newline)
                        points.append((.linebreak, result.startIndex..<tagEnd))
                    default:
                        push(tag, attributes)
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

        if let (_, unbalancedParagraphTag) = tags[.p]?.popLast() {
            points.append((.paragraph, unbalancedParagraphTag.upperBound..<result.endIndex))
        }

        return FormattedString(text: result, formatting: points)
    }
}
