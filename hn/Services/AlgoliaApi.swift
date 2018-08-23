import PromiseKit

struct Algolia {
  enum Endpoint {
    case item(Id)
    case user(String)
  }
}

extension Algolia: ResolveItem {
  func item(id: Id) -> Promise<Item> {
    return Webservice().load(resource: Resource(
      url: Endpoint.item(id).url,
      parseJSON: Item.init(algoliaResponse:)
    ))
  }
}

extension Algolia: ResolveUser {
  func user(username: String) -> Promise<User> {
    return Webservice().load(resource: Resource(
      url: Endpoint.user(username).url,
      parseJSON: User.init(algoliaResponse:)
    ))
  }
}

extension Item.PostType {
  init?(algoliaResponse type: String) {
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
  init?(algoliaResponse json: JSONDictionary) {
    guard
      let id = json["id"] as? Int,
      let type = (json["type"] as? String).flatMap(PostType.init(algoliaResponse:))
    else {
      return nil
    }
    self.id = id
    self.type = type
    title = json["title"] as? String
    text = json["text"] as? String
    score = json["points"] as? Int
    author = json["author"] as? String
    time = json["created_at_i"] as? Int
    url = json["url"] as? String
    parent = json["parent"] as? Int
    if let children = json["children"] as? [JSONDictionary] {
      kids = children.flatMap(Item.init(algoliaResponse:)).map(Reference.value)
    } else {
      kids = []
    }
    descendants = kids.count
    parts = .none
    dead = false
    deleted = author == .none
  }
}

extension User {
  init?(algoliaResponse json: JSONDictionary) {
    guard
      let username = json["username"] as? String,
      let karma = json["karma"] as? Int,
      let created = json["created_at_i"] as? Int
    else {
      return nil
    }
    self.username = username
    self.karma = karma
    self.created = created
    id = json["id"] as? Int
    about = json["about"] as? String
    delay = json["delay"] as? Int
  }
}

extension Algolia.Endpoint {
  static let baseUrl = "http://hn.algolia.com/api/v1"

  var path: String {
    switch self {
    case let .item(id): return "/items/\(id)"
    case let .user(username): return "/users/\(username)"
    }
  }

  var url: URL {
    return URL(string: "\(Algolia.Endpoint.baseUrl)\(path)")!
  }
}
