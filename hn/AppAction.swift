import Foundation
import ReSwift

enum AppAction: Action {
    case fetchTopStories
    case fetchedIds(ids: [Int])
    case fetchStories(ids: [Int])
    case fetchedStories(stories: [Story])
}

func fetchTopStories(state: AppState, store: Store<AppState>) -> AppAction? {
    fetch(.topStories) { (ids: [Int]) in
        DispatchQueue.main.async {
            store.dispatch(AppAction.fetchedIds(ids: ids))
            store.dispatch(fetchNextStoryBatch)
        }
    }
    return .fetchTopStories
}

func fetchNextStoryBatch(state: AppState, store: Store<AppState>) -> AppAction? {
    if !state.ids.isEmpty && state.ids.count == state.stories.count {
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
                    store.dispatch(AppAction.fetchedStories(stories: stories))
                }
            }
        }
    }

    return .fetchStories(ids: ids)
}
