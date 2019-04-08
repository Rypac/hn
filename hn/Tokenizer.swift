import Foundation

public protocol Token {}

public protocol Tokenizer {
  associatedtype Value: Token
  associatedtype Error: Swift.Error

  init(text: String)

  mutating func nextToken() -> Result<Value, Error>?
}
