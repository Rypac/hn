import Foundation

enum Firebase {
  case topStories
  case newStories
  case bestStories
  case showHN
  case askHN
  case jobs
  case updates
  case item(Int)
  case user(String)

  private static let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0")!

  var url: URL {
    return Firebase.baseURL.appendingPathComponent(path)
  }

  private var path: String {
    switch self {
    case .topStories: return "/topstories.json"
    case .newStories: return "/newstories.json"
    case .bestStories: return "/beststories.json"
    case .showHN: return "/showstories.json"
    case .askHN: return "/askstories.json"
    case .jobs: return "/jobstories.json"
    case .updates: return "/updates.json"
    case .item(let id): return "/item/\(id).json"
    case .user(let username): return "/user/\(username).json"
    }
  }
}
