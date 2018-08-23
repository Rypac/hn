import Foundation

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
    return HtmlParser.parse(self) ?? FormattedString(text: self, formatting: [])
  }
}
