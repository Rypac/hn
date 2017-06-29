import Alamofire
import PromiseKit

struct Firebase {
    struct Item {
        let id: Int
        let title: String?
        let text: String?
        let score: Int?
        let by: String?
        let time: Int?
        let type: String?
        let url: String?
        let parent: Int?
        let descendants: Int?
        let kids: [Int]?
        let parts: [Int]?
        let dead: Bool
        let deleted: Bool
    }

    struct User {
        let id: String
        let karma: Int
        let created: Int
        let about: String?
        let submitted: [Int]?
        let delay: Int?
    }

    enum Endpoint {
        case topStories
        case newStories
        case bestStories
        case showHN
        case askHN
        case jobs
        case updates
        case user(Int)
        case item(Int)
    }
}

extension Firebase.Item: JsonDecodable {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int else {
            return nil
        }
        self.id = id
        title = json["title"] as? String
        text = json["text"] as? String
        score = json["score"] as? Int
        by = json["by"] as? String
        time = json["time"] as? Int
        type = json["type"] as? String
        url = json["url"] as? String
        parent = json["parent"] as? Int
        descendants = json["descendants"] as? Int
        kids = json["kids"] as? [Int]
        parts = json["parts"] as? [Int]
        deleted = json["deleted"] as? Bool ?? false
        dead = json["dead"] as? Bool ?? false
    }
}

extension Firebase.Item {
    func toItem() -> Item {
        return Item(
            id: id,
            title: title,
            text: text,
            score: score,
            author: by,
            time: time,
            type: type,
            url: url,
            parent: parent,
            descendants: descendants,
            kids: kids?.map(Reference.id) ?? [],
            parts: parts,
            dead: dead,
            deleted: deleted)
    }
}

extension Firebase.User: JsonDecodable {
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? String,
            let karma = json["karma"] as? Int,
            let created = json["created"] as? Int
        else {
            return nil
        }
        self.id = id
        self.karma = karma
        self.created = created
        about = json["about"] as? String
        submitted = json["submitted"] as? [Int]
        delay = json["delay"] as? Int
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
        case .user(let id): return "/user/\(id).json"
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

func fetch(stories: ItemType) -> Promise<[Int]> {
    return fetch(stories.endpoint)
}

func fetch(item id: Int) -> Promise<Item> {
    return fetch(Firebase.Endpoint.item(id)).then { (item: Firebase.Item) in
        Promise(value: item.toItem())
    }
}
