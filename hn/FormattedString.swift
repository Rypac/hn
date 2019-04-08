import Foundation

public enum Formatting {
  case paragraph
  case url
  case italic
  case bold
  case underline
  case code
  case preformatted
  case linebreak
}

public struct FormattedString {
  public let text: String
  public let formatting: [FormattingOptions]
}

public struct FormattingOptions {
  public let type: Formatting
  public let attributes: Attributes
  public let range: Range<String.Index>

  public init(_ type: Formatting, range: Range<String.Index>, attributes: Attributes = Attributes([])) {
    self.type = type
    self.range = range
    self.attributes = attributes
  }
}

public struct Attributes {
  public let attributes: [String]

  public init(_ attributes: [String]) {
    self.attributes = attributes
  }

  public func find(_ attribute: String) -> String? {
    return attributes.lazy
      .compactMap { $0.slice(from: "\(attribute)=\"", to: "\"") }
      .first?
      .decodingHtmlEntities()
  }
}
