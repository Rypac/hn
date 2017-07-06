import ReSwift

struct AppState: StateType {
    var tabs = [ItemType: ItemList]()
    var selectedTab: ItemType?
    var selectedItem: ItemDetails?
}

struct ItemList {
    var ids = [Int]()
    var posts = [Post]()
    var fetching: ContainerFetchState? = .none
}

struct ItemDetails {
    var post: Post
    var comments: [Comment] = []
    var fetching: FetchState? = .none

    init(_ post: Post) {
        self.post = post
    }
}

enum ItemType {
    case topStories
    case newStories
    case bestStories
    case showHN
    case askHN
    case jobs
    case updates
}

extension ItemType: CustomStringConvertible {
    var description: String {
        switch self {
        case .topStories: return "Top Stories"
        case .newStories: return "New Stories"
        case .bestStories: return "Best Stories"
        case .showHN: return "Show HN"
        case .askHN: return "Ask HN"
        case .jobs: return "Jobs"
        case .updates: return "Updates"
        }
    }
}

enum ContainerFetchState {
    case list(FetchState)
    case items(FetchState)
}

enum FetchState {
    case started
    case finished
}

struct User {
    let username: String
    let karma: Int
    let created: Int
    let id: Int?
    let about: String?
    let delay: Int?
}
