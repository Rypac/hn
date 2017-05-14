import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

struct Story: Mappable {
    var id: Int!
    var author: String!
    var descendants: Int!
    var kids: [Int]!
    var score: Int!
    var title: String!
    var type: String!
    var url: String!

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        score <- map["score"]
        author <- map["author"]
        type <- map["type"]
        url <- map["url"]
        descendants <- map["descendants"]
        kids <- map["kids"]
    }
}

enum Endpoint: CustomStringConvertible {
    case topStories
    case newStories
    case bestStories
    case showHN
    case askHN
    case jobs
    case updates
    case user(Int)
    case item(Int)

    var description: String {
        let url = { (resource: String) in "https://hacker-news.firebaseio.com/v0/\(resource).json" }
        switch self {
        case .topStories: return url("topstories")
        case .newStories: return url("newstories")
        case .bestStories: return url("beststories")
        case .showHN: return url("showstories")
        case .askHN: return url("askstories")
        case .jobs: return url("jobstories")
        case .updates: return url("updates")
        case .item(let id): return url("item/\(id)")
        case .user(let id): return url("user/\(id)")
        }
    }
}

func fetch<T: Mappable>(_ endpoint: Endpoint, onCompletion: @escaping (T) -> Void) {
    Alamofire.request(endpoint.description).validate().responseObject { (response: DataResponse<T>) in
        response.result.value.map(onCompletion)
    }
}

func fetch<T: Mappable>(_ endpoint: Endpoint, onCompletion: @escaping ([T]) -> Void) {
    Alamofire.request(endpoint.description).validate().responseArray { (response: DataResponse<[T]>) in
        response.result.value.map(onCompletion)
    }
}

func fetchIds(_ endpoint: Endpoint, onCompletion: @escaping ([Int]) -> Void) {
    Alamofire.request(endpoint.description).validate().responseJSON { response in
        if let json = response.result.value as? [Int] {
            onCompletion(json)
        }
    }
}
