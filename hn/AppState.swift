import Foundation
import ReSwift

struct AppState: StateType {
    var tabs = [ItemType: ItemList]()
    var selectedTab: ItemList?
    var selectedItem: ItemDetails?
}

struct ItemList {
    var ids = [Int]()
    var items = [Item]()
    var fetching: ContainerFetchState? = .none
}

struct ItemDetails {
    var item: Item
    var fetching: FetchState? = .none

    init(_ item: Item) {
        self.item = item
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

struct Item {
    let id: Int
    let title: String?
    let text: String?
    let score: Int?
    let author: String?
    let time: Int?
    let type: String?
    let url: String?
    let parent: Int?
    let descendants: Int?
    private(set) var kids: [Reference<Item>]
    let parts: [Int]?
    let dead: Bool
    let deleted: Bool

    func with(kids: [Item]) -> Item {
        var copy = self
        copy.kids = kids.map(Reference.value)
        return copy
    }
}

enum Reference<T> {
    case id(Int)
    case value(T)
}
