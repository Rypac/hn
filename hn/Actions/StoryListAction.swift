import Foundation
import ReSwift
import Alamofire
import UIKit

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

enum StoryListAction: Action {
    case view(Story)
    case dismiss(Story)
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

typealias ActionCreator<T: StateType> = (T, Store<T>) -> Action?

func fetchStories(_ type: StoryType) -> ActionCreator<AppState> {
    return { state, store in
        guard let storyList = state.tabs[type] else {
            return .none
        }
        let action = storyList.ids.isEmpty ? fetchStoryList : fetchNextStoryBatch
        return action(type)(state, store)
    }
}

func fetchStoryList(_ type: StoryType) -> ActionCreator<AppState> {
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

func fetchNextStoryBatch(_ type: StoryType) -> ActionCreator<AppState> {
    return { state, store in
        guard
            let state = state.tabs[type],
            state.ids.count > state.stories.count
        else {
            return .none
        }

        let start = state.stories.count
        let end = start + min(16, state.ids.count - state.stories.count)
        let ids = Array(state.ids[start..<end])

        let requestGroup = DispatchGroup()
        var stories = [Story]()
        ids.forEach { id in
            requestGroup.enter()
            fetch(.item(id)) { (story: Result<Story>) in
                story.withValue {
                    stories.append($0)
                }
                requestGroup.leave()
            }
        }

        requestGroup.notify(queue: .main) {
            store.dispatch(FetchAction(storyType: type, action: .fetchedStories(stories)))
        }

        return FetchAction(storyType: type, action: .fetchStories(ids: ids))
    }
}

func routeTo(_ story: Story, from viewController: UIViewController?) -> ActionCreator<AppState> {
    return { state, store in
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(StoryDetailViewController(story), animated: true)
            return StoryListAction.view(story)
        }
        return .none
    }
}
