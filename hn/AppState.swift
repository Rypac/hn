import Foundation
import ReSwift

struct AppState: StateType {
    var tabs = [StoryType: StoryList]()
    var selectedTab: StoryList?
    var selectedStory: StoryDetails?
}

struct StoryList {
    var ids = [Int]()
    var stories = [Story]()
    var fetchingMore = false
}

struct StoryDetails {
    var story: Story
    var comments = [Comment]()
    var fetchingMore = false

    init(_ story: Story) {
        self.story = story
    }
}

enum StoryType {
    case topStories
    case newStories
    case bestStories
    case showHN
    case askHN
    case jobs
    case updates
}

extension StoryType: CustomStringConvertible {
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
