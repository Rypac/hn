// swiftlint:disable cyclomatic_complexity
import Foundation

struct HtmlParser {
  static func parse(_ html: String) -> FormattedString? {
    var parser = HtmlParser(text: html)
    return parser.parse()
  }

  private var tokenizer: HtmlTokenizer
  private var result: String = ""
  private var points: [FormattingOptions] = []
  private var tags: [HtmlTag: [(String.Index, HtmlAttributes)]] = [:]
  private var dealtWithOpeningTag = false

  private init(text: String) {
    tokenizer = HtmlTokenizer(text: text)
    result.reserveCapacity(text.utf8.count)
  }

  private mutating func parse() -> FormattedString? {
    while let token = tokenizer.nextToken() {
      switch token {
      case let .success(tag):
        switch tag {
        case let .open(tag, attributes):
          switch tag {
          case .p:
            handleParagraphTag()
            push(tag, attributes)
          case .br:
            let tagEnd = result.endIndex
            append(newline)
            points.append(FormattingOptions(.linebreak, range: result.startIndex ..< tagEnd))
          default:
            push(tag, attributes)
          }
        case let .close(tag):
          pop(tag)
        case let .entity(char), let .text(char):
          result.unicodeScalars.append(char)
        }
      case let .error(error) where error != .unknownTag:
        return .none
      default:
        break
      }
    }

    if let (index, _) = tags[.p]?.last {
      points.append(FormattingOptions(.paragraph, range: index ..< result.endIndex))
    }

    return FormattedString(text: result, formatting: points)
  }

  private mutating func append(_ char: UnicodeScalar) {
    result.unicodeScalars.append(char)
  }

  private mutating func push(_ tag: HtmlTag, _ attributes: HtmlAttributes) {
    var stack = tags[tag] ?? []
    stack.append(result.endIndex, attributes)
    tags[tag] = stack
  }

  private mutating func pop(_ tag: HtmlTag) {
    if let (index, attributes) = tags[tag]?.popLast(), let type = Formatting(from: tag) {
      points.append(
        FormattingOptions(
          type,
          range: index ..< result.endIndex,
          attributes: Attributes(attributes)
        )
      )
    }
  }

  private mutating func handleParagraphTag() {
    if let (index, _) = tags[.p]?.popLast() {
      let openTagEnd = result.endIndex
      append(newline)
      append(newline)
      points.append(FormattingOptions(.paragraph, range: index ..< openTagEnd))
    } else if !dealtWithOpeningTag {
      if !result.isEmpty {
        let openTagEnd = result.endIndex
        append(newline)
        append(newline)
        points.append(FormattingOptions(.paragraph, range: result.startIndex ..< openTagEnd))
      }
      dealtWithOpeningTag = true
    } else {
      append(newline)
      append(newline)
    }
  }
}

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

private let newline: UnicodeScalar = "\n"
