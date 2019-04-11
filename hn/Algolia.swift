import Foundation

enum Algolia {
  case item(Int)
  case user(String)

  private static let baseURL = URL(string: "http://hn.algolia.com/api/v1")!

  var url: URL {
    return Algolia.baseURL.appendingPathComponent(path)
  }

  private var path: String {
    switch self {
    case let .item(id): return "/items/\(id)"
    case let .user(username): return "/users/\(username)"
    }
  }
}
