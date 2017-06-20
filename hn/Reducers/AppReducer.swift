import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
    case let action as FetchAction:
        guard var storyList = state.tabs[action.storyType] else {
            return state
        }
        switch action.action {
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
        state.tabs[action.storyType] = storyList
    case let action as StoryListAction:
        switch action {
        case let .view(story):
            state.selectedStory = StoryDetails(story)
        case .dismiss(_):
            state.selectedStory = .none
        }
    case let action as CommentFetchAction:
        switch action {
        case .fetch(comments: _):
            state.selectedStory?.fetchingMore = true
        case let .fetched(comments: comments):
            state.selectedStory?.comments += comments
            state.selectedStory?.fetchingMore = false
        }
    default:
        break
    }

    return state
}
