import Foundation
import Alamofire

struct Item {
    let id: Int
    let title: String?
    let text: String?
    let score: Int?
    let by: String?
    let time: Int?
    let type: String?
    let url: String?
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

extension Item: JsonDecodable {
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
        descendants = json["descendants"] as? Int
        kids = json["kids"] as? [Int]
        parts = json["parts"] as? [Int]
        deleted = json["deleted"] as? Bool ?? false
        dead = json["dead"] as? Bool ?? false
    }
}

extension User: JsonDecodable {
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

extension Endpoint: URLConvertible {
    static let baseUrl = "https://hacker-news.firebaseio.com/v0"

    func asURL() throws -> URL {
        return try "\(Endpoint.baseUrl)/\(path)".asURL()
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
