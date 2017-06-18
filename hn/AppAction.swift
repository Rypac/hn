import Foundation
import ReSwift

struct FetchAction: Action {
    let storyType: StoryType
    let action: StoryFetchState
}

enum StoryFetchState {
    case fetch
    case fetchedIds([Int])
    case fetchStories(ids: [Int])
    case fetchedStories([Story])
}

extension StoryType {
    var endpoint: Endpoint {
        switch self {
        case .topStories: return .topStories
        case .newStories: return .newStories
        case .bestStories: return .bestStories
        case .showHN: return .showHN
        case .askHN: return .askHN
        case .jobs: return .jobs
        case .updates: return .updates
        }
    }
}

func fetchInitialBatch(_ type: StoryType) -> ((AppState, Store<AppState>) -> FetchAction?) {
    return { state, store in
        fetch(type.endpoint) { (ids: [Int]) in
            DispatchQueue.main.async {
                store.dispatch(FetchAction(storyType: type, action: .fetchedIds(ids)))
                store.dispatch(fetchNextStoryBatch(type))
            }
        }
        return FetchAction(storyType: type, action: .fetch)
    }
}

func fetchNextStoryBatch(_ type: StoryType) -> ((AppState, Store<AppState>) -> FetchAction?) {
    return { state, store in
        guard let state = state.tabs[type] else {
            return .none
        }

        if state.ids.count == state.stories.count {
            return .none
        }

        let start = state.stories.count
        let end = start + min(20, state.ids.count - state.stories.count) - 1
        let ids = Array(state.ids[start..<end])

        var stories = [Story]()
        ids.forEach { id in
            fetch(.item(id)) { (story: Story) in
                stories.append(story)
                if stories.count == ids.count {
                    DispatchQueue.main.async {
                        store.dispatch(FetchAction(storyType: type, action: .fetchedStories(stories)))
                    }
                }
            }
        }

        return FetchAction(storyType: type, action: .fetchStories(ids: ids))
    }
}
