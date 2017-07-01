import Alamofire
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
        case item(Int)
        case user(String)
    }

    static func fetch(stories: ItemType) -> Promise<[Int]> {
        return request(stories.endpoint)
    }

    static func fetch(item id: Int) -> Promise<Item> {
        return request(Endpoint.item(id), withMapper: Item.init(firebaseResponse:))
    }

    static func fetch(user username: String) -> Promise<User> {
        return request(Endpoint.user(username), withMapper: User.init(firebaseResponse:))
    }
}

extension Item {
    init?(firebaseResponse json: [String: Any]) {
        guard let id = json["id"] as? Int else {
            return nil
        }
        self.id = id
        title = json["title"] as? String
        text = json["text"] as? String
        score = json["score"] as? Int
        author = json["by"] as? String
        time = json["time"] as? Int
        type = json["type"] as? String
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
    init?(firebaseResponse json: [String: Any]) {
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

extension Firebase.Endpoint: URLConvertible {
    static let baseUrl = "https://hacker-news.firebaseio.com/v0"

    func asURL() throws -> URL {
        return try "\(Firebase.Endpoint.baseUrl)/\(path)".asURL()
    }

    var path: String {
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
