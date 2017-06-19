import Foundation
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
    case let fetchAction as FetchAction:
        guard var storyList = state.tabs[fetchAction.storyType] else {
            return state
        }
        switch fetchAction.action {
        case .fetch:
            storyList.fetchingMore = true
        case let .fetchedIds(ids):
            storyList.ids = ids
            storyList.fetchingMore = false
        case .fetchStories(_):
            storyList.fetchingMore = true
        case let .fetchedStories(stories):
            storyList.stories += stories
            storyList.fetchingMore = false
        }
        state.tabs[fetchAction.storyType] = storyList
    case let storyListAction as StoryListAction:
        switch storyListAction {
        case let .view(story):
            state.selectedStory = story
        case .dismiss(_):
            state.selectedStory = .none
        }
    default:
        break
    }

    return state
}
