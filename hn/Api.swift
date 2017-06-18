import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

struct Story {
    let id: Int
    let title: String
    let text: String?
    let score: Int
    let author: String
    let type: String
    let url: String?
    let descendants: Int?
    let kids: [Int]?
}

extension Story: ImmutableMappable {
    init(map: Map) throws {
        id = try map.value("id")
        title = try map.value("title")
        text = try? map.value("text")
        score = try map.value("score")
        author = try map.value("by")
        type = try map.value("type")
        url = try? map.value("url")
        descendants = try? map.value("descendants")
        kids = try? map.value("kids")
    }

    mutating func mapping(map: Map) {
        id >>> map["id"]
        title >>> map["title"]
        text >>> map["text"]
        score >>> map["score"]
        author >>> map["by"]
        type >>> map["type"]
        url >>> map["url"]
        descendants >>> map["descendants"]
        kids >>> map["kids"]
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
