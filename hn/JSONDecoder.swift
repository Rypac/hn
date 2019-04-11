import Foundation

extension JSONDecoder {
  func decode<T>(_ data: Data) throws -> T where T: Decodable {
    return try decode(T.self, from: data)
  }
}
