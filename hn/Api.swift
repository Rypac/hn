import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

struct Story: ImmutableMappable {
    var id: Int
    var author: String
    var descendants: Int
    var kids: [Int]
    var score: Int
    var title: String
    var type: String
    var url: String

    init(map: Map) throws {
        id = try map.value("id")
        title = try map.value("title")
        score = try map.value("score")
        author = try map.value("by")
        type = try map.value("type")
        url = try map.value("url")
        descendants = (try? map.value("descendants")) ?? 0
        kids = (try? map.value("kids")) ?? []
    }

    mutating func mapping(map: Map) {
        id >>> map["id"]
        title >>> map["title"]
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

    var url: String {
        return "\(self.baseUrl)/\(self.path)"
    }

    var baseUrl: String {
        return "https://hacker-news.firebaseio.com/v0"
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

func fetch<T: ImmutableMappable>(_ endpoint: Endpoint, onCompletion: @escaping (T) -> Void) {
    Alamofire.request(endpoint.url).validate().responseObject { (response: DataResponse<T>) in
        response.result.value.map(onCompletion)
    }
}

func fetch<T: ImmutableMappable>(_ endpoint: Endpoint, onCompletion: @escaping ([T]) -> Void) {
    Alamofire.request(endpoint.url).validate().responseArray { (response: DataResponse<[T]>) in
        response.result.value.map(onCompletion)
    }
}

func fetch<T>(_ endpoint: Endpoint, onCompletion: @escaping ([T]) -> Void) {
    Alamofire.request(endpoint.url).validate().responseJSON { response in
        if let json = response.result.value as? [T] {
            onCompletion(json)
        }
    }
}
