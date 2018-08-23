import Foundation

enum Formatting {
  case paragraph
  case url
  case italic
  case bold
  case underline
  case code
  case preformatted
  case linebreak
}

struct FormattedString {
  let text: String
  let formatting: [FormattingOptions]
}

struct FormattingOptions {
  let type: Formatting
  let attributes: Attributes
  let range: Range<String.Index>

  init(_ type: Formatting, range: Range<String.Index>, attributes: Attributes = Attributes()) {
    self.type = type
    self.range = range
    self.attributes = attributes
  }
}

struct Attributes {
  let attributes: [String]

  init(_ attributes: [String] = []) {
    self.attributes = attributes
  }

  func find(_ attribute: String) -> String? {
    return attributes.lazy
      .compactMap { $0.slice(from: "\(attribute)=\"", to: "\"") }
      .first?
      .decodingHtmlEntities()
  }
}
