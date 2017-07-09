import Alamofire
import PromiseKit

struct Algolia {
    enum Endpoint {
        case item(Int)
        case user(String)
    }

    static func fetch(item id: Int) -> Promise<Item> {
        return request(Endpoint.item(id), withMapper: Item.init(algoliaResponse:))
    }

    static func fetch(user username: String) -> Promise<User> {
        return request(Endpoint.user(username), withMapper: User.init(algoliaResponse:))
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
    init?(algoliaResponse json: [String: Any]) {
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
        if let children = json["children"] as? [[String: Any]] {
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
    init?(algoliaResponse json: [String: Any]) {
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

extension Algolia.Endpoint: URLConvertible {
    static let baseUrl = "http://hn.algolia.com/api/v1"

    func asURL() throws -> URL {
        return try "\(Algolia.Endpoint.baseUrl)\(path)".asURL()
    }

    var path: String {
        switch self {
        case .item(let id): return "/items/\(id)"
        case .user(let username): return "/users/\(username)"
        }
    }
}
