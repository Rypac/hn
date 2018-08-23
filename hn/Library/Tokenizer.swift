import Foundation

protocol Token {}

enum TokenResult<T: Token, E: Error> {
  case success(T)
  case error(E)
}

protocol Tokenizer {
  associatedtype Value: Token
  associatedtype Error: Swift.Error

  init(text: String)
  mutating func nextToken() -> TokenResult<Value, Error>?
}
