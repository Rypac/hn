import Foundation
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    guard
        let action = action as? FetchAction,
        var storyList = state.tabs[action.storyType]
    else {
        return state
    }

    switch action.action {
    case .fetch:
        storyList.fetchingMore = true
    case let .fetchedIds(ids):
        storyList.ids = ids
        storyList.fetchingMore = true
    case .fetchStories(_):
        storyList.fetchingMore = true
    case let .fetchedStories(stories):
        storyList.stories += stories
        storyList.fetchingMore = false
    }
    state.tabs[action.storyType] = storyList
    return state
}
