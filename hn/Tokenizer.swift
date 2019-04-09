import Foundation

public protocol Tokenizer {
  associatedtype Token
  associatedtype Error: Swift.Error

  init(text: String)

  mutating func nextToken() -> Result<Token, Error>?
}
