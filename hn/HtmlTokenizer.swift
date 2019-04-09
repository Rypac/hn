import Foundation

public enum HtmlTag: String {
  case p, a, b, i, u, br, pre, code
}

public typealias HtmlAttributes = [String]

public enum HtmlToken {
  case open(HtmlTag, HtmlAttributes)
  case close(HtmlTag)
  case entity(UnicodeScalar)
  case text(UnicodeScalar)
}

public enum HtmlTokenError: Error {
  case unknownTag
  case invalidTag
  case invalidEntity
}

public struct HtmlTokenizer: Tokenizer {
  typealias Token = HtmlToken
  typealias Error = HtmlTokenError

  private var iterator: String.UnicodeScalarView.Iterator
  private var pushedBackScalar: UnicodeScalar?

  public init(text: String) {
    iterator = text.unicodeScalars.makeIterator()
  }

  public mutating func nextToken() -> Result<Token, Error>? {
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

  private mutating func parseTag() -> Result<Token, Error> {
    var tag: String? = .none
    var text = String()
    var attributes = HtmlAttributes()
    var isCloseTag = false

    let pushTag = {
      if tag == .none {
        tag = text
      } else {
        attributes.append(text)
      }
    }

    while let char = nextCharacter() {
      switch char {
      case HtmlTagId.separator:
        if !text.isEmpty {
          pushTag()
          text = ""
        }
      case HtmlTagId.close where tag == .none:
        isCloseTag = true
      case HtmlTagId.end:
        pushTag()
        return tag.flatMap(HtmlTag.init(rawValue:))
          .map { isCloseTag ? .close($0) : .open($0, attributes) }
          .map(Result.success)
          .or(.failure(.unknownTag))
      default:
        text.unicodeScalars.append(char)
      }
    }
    return .failure(.invalidTag)
  }

  private mutating func parseEntity() -> Result<Token, Error> {
    var char = nextCharacter()
    guard char == HtmlEntity.number else {
      var entityName = String()
      while let ch = char, ch != HtmlEntity.end {
        entityName.unicodeScalars.append(ch)
        char = nextCharacter()
      }
      return HtmlEntity.decode(entityName)
        .map(HtmlToken.entity)
        .map(Result.success)
        .or(.failure(.invalidEntity))
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

    return UInt32(number, radix: radix)
      .flatMap(UnicodeScalar.init)
      .flatMap(HtmlToken.entity)
      .map(Result.success)
      .or(.failure(.invalidEntity))
  }
}

private enum HtmlTagId {
  static let start: UnicodeScalar = "<"
  static let end: UnicodeScalar = ">"
  static let close: UnicodeScalar = "/"
  static let separator: UnicodeScalar = " "
}

private enum HtmlEntity {
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
