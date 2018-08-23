import PromiseKit

struct Firebase {
  enum Endpoint {
    case topStories
    case newStories
    case bestStories
    case showHN
    case askHN
    case jobs
    case updates
    case item(Id)
    case user(String)
  }
}

extension Firebase: ResolveStories {
  func stories(_ type: ItemType) -> Promise<[Id]> {
    return Webservice().load(resource: Resource(url: type.endpoint.url))
  }
}

extension Firebase: ResolveItem {
  func item(id: Id) -> Promise<Item> {
    return Webservice().load(resource: Resource(
      url: Endpoint.item(id).url,
      parseJSON: Item.init(firebaseResponse:)
    ))
  }
}

extension Firebase: ResolveUser {
  func user(username: String) -> Promise<User> {
    return Webservice().load(resource: Resource(
      url: Endpoint.user(username).url,
      parseJSON: User.init(firebaseResponse:)
    ))
  }
}

extension Item.PostType {
  init?(firebaseResponse type: String) {
    switch type {
    case "story": self = .story
    case "comment": self = .comment
    case "job": self = .job
    case "poll": self = .poll
    case "pollopt": self = .pollOption
    default: return nil
    }
  }
}

extension Item {
  init?(firebaseResponse json: JSONDictionary) {
    guard
      let id = json["id"] as? Int,
      let type = (json["type"] as? String).flatMap(PostType.init(firebaseResponse:))
    else {
      return nil
    }
    self.id = id
    self.type = type
    title = json["title"] as? String
    text = json["text"] as? String
    score = json["score"] as? Int
    author = json["by"] as? String
    time = json["time"] as? Int
    url = json["url"] as? String
    parent = json["parent"] as? Int
    descendants = json["descendants"] as? Int
    kids = (json["kids"] as? [Int]).map { $0.map(Reference.id) } ?? []
    parts = json["parts"] as? [Int]
    deleted = json["deleted"] as? Bool ?? false
    dead = json["dead"] as? Bool ?? false
  }
}

extension User {
  init?(firebaseResponse json: JSONDictionary) {
    guard
      let username = json["id"] as? String,
      let karma = json["karma"] as? Int,
      let created = json["created"] as? Int
    else {
      return nil
    }
    self.username = username
    self.karma = karma
    self.created = created
    about = json["about"] as? String
    delay = json["delay"] as? Int
    id = .none
  }
}

extension Firebase.Endpoint {
  static let baseUrl = "https://hacker-news.firebaseio.com/v0"

  var path: String {
    switch self {
    case .topStories: return "/topstories.json"
    case .newStories: return "/newstories.json"
    case .bestStories: return "/beststories.json"
    case .showHN: return "/showstories.json"
    case .askHN: return "/askstories.json"
    case .jobs: return "/jobstories.json"
    case .updates: return "/updates.json"
    case let .item(id): return "/item/\(id).json"
    case let .user(username): return "/user/\(username).json"
    }
  }

  var url: URL {
    return URL(string: "\(Firebase.Endpoint.baseUrl)\(path)")!
  }
}

extension ItemType {
  var endpoint: Firebase.Endpoint {
    switch self {
    case .topStories: return .topStories
    case .newStories: return .newStories
    case .bestStories: return .bestStories
    case .showHN: return .showHN
    case .askHN: return .askHN
    case .jobs: return .jobs
    case .updates: return .updates
    }
  }
}
