import Alamofire
import PromiseKit

struct Algolia {
    struct Item {
        let id: Int
        let title: String?
        let text: String?
        let points: Int?
        let author: String?
        let time: Int?
        let type: String?
        let url: String?
        let parent: Int?
        let story: Int?
        let children: [Item]?
    }

    struct User {
        let id: Int
        let username: String
        let karma: Int
        let created: Int
        let about: String?
        let delay: Int?
    }

    enum Endpoint {
        case item(Int)
        case user(String)
    }

    static func fetch(item id: Int) -> Promise<hn.Item> {
        return request(Endpoint.item(id)).then { (item: Item) in
            Promise(value: item.toItem())
        }
    }
}

extension Algolia.Item: JsonDecodable {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int else {
            return nil
        }
        self.id = id
        title = json["title"] as? String
        text = json["text"] as? String
        points = json["points"] as? Int
        author = json["author"] as? String
        time = json["created_at_i"] as? Int
        type = json["type"] as? String
        url = json["url"] as? String
        story = json["story"] as? Int
        parent = json["parent"] as? Int
        if let children = json["children"] as? [[String: Any]] {
            self.children = children.flatMap(Algolia.Item.init(json:))
        } else {
            children = .none
        }
    }
}

extension Algolia.Item {
    func toItem() -> Item {
        return Item(
            id: id,
            title: title,
            text: text,
            score: points,
            author: author,
            time: time,
            type: type,
            url: url,
            parent: parent,
            descendants: children?.count,
            kids: children?.map { .value($0.toItem()) } ?? [],
            parts: .none,
            dead: false,
            deleted: author == .none)
    }
}

extension Algolia.User: JsonDecodable {
    init?(json: [String: Any]) {
        guard
            let id = json["id"] as? Int,
            let username = json["username"] as? String,
            let karma = json["karma"] as? Int,
            let created = json["created_at_i"] as? Int
        else {
            return nil
        }
        self.id = id
        self.username = username
        self.karma = karma
        self.created = created
        about = json["about"] as? String
        delay = json["delay"] as? Int
    }
}

extension Algolia.Endpoint: URLConvertible {
    static let baseUrl = "http://hn.algolia.com/api/v1"

    func asURL() throws -> URL {
        return try "\(Algolia.Endpoint.baseUrl)/\(path)".asURL()
    }

    var path: String {
        switch self {
        case .item(let id): return "/items/\(id)"
        case .user(let username): return "/users/\(username)"
        }
    }
}
