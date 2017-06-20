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
    var fetchingMore = false
}

struct ItemDetails {
    var item: Item
    var comments = [Item]()
    var fetchingMore = false

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
