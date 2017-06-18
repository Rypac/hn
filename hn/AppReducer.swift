import Foundation
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()
    guard let action = action as? AppAction else {
        return state
    }

    switch action {
    case .fetchTopStories:
        state.fetchingMore = true
    case let .fetchedIds(ids):
        state.ids = ids
        state.fetchingMore = true
    case .fetchStories(_):
        state.fetchingMore = true
    case let .fetchedStories(stories):
        state.stories += stories
        state.fetchingMore = false
    }
    return state
}
