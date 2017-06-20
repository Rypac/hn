import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

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

extension Item: ImmutableMappable {
    init(map: Map) throws {
        id = try map.value("id")
        title = try? map.value("title")
        text = try? map.value("text")
        score = try? map.value("score")
        by = try? map.value("by")
        time = try? map.value("time")
        type = try? map.value("type")
        url = try? map.value("url")
        descendants = try? map.value("descendants")
        kids = try? map.value("kids")
        parts = try? map.value("parts")
        deleted = (try? map.value("deleted")) ?? false
        dead = (try? map.value("dead")) ?? false
    }

    mutating func mapping(map: Map) {
        id >>> map["id"]
        title >>> map["title"]
        text >>> map["text"]
        score >>> map["score"]
        by >>> map["by"]
        time >>> map["time"]
        type >>> map["type"]
        url >>> map["url"]
        descendants >>> map["descendants"]
        kids >>> map["kids"]
        parts >>> map["parts"]
        dead >>> map["dead"]
        deleted >>> map["deleted"]
    }
}

extension User: ImmutableMappable {
    init(map: Map) throws {
        id = try map.value("id")
        karma = try map.value("karma")
        created = try map.value("created")
        about = try? map.value("about")
        submitted = try? map.value("submitted")
        delay = try? map.value("delay")
    }

    mutating func mapping(map: Map) {
        id >>> map["id"]
        karma >>> map["karma"]
        created >>> map["created"]
        about >>> map["about"]
        submitted >>> map["submitted"]
        delay >>> map["delay"]
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

func fetch<T: ImmutableMappable>(_ endpoint: Endpoint, onCompletion: @escaping (Result<T>) -> Void) {
    Alamofire.request(endpoint).validate().responseObject { (response: DataResponse<T>) in
        onCompletion(response.result)
    }
}

func fetch<T: ImmutableMappable>(_ endpoint: Endpoint, onCompletion: @escaping (Result<[T]>) -> Void) {
    Alamofire.request(endpoint).validate().responseArray { (response: DataResponse<[T]>) in
        onCompletion(response.result)
    }
}

func fetch<T>(_ endpoint: Endpoint, onCompletion: @escaping (T) -> Void) {
    Alamofire.request(endpoint).validate().responseJSON { response in
        (response.result.value as? T).map(onCompletion)
    }
}

func fetch<T>(_ endpoint: Endpoint, onCompletion: @escaping ([T]) -> Void) {
    Alamofire.request(endpoint).validate().responseJSON { response in
        (response.result.value as? [T]).map(onCompletion)
    }
}
