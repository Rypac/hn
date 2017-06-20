import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
    case let action as FetchAction:
        guard var itemList = state.tabs[action.itemType] else {
            return state
        }
        switch action.action {
        case .fetch:
            itemList.fetchingMore = true
        case let .fetchedIds(ids):
            itemList.ids = ids
            itemList.fetchingMore = true
        case .fetchItems(_):
            itemList.fetchingMore = true
        case let .fetchedItems(items):
            itemList.items += items
            itemList.fetchingMore = false
        }
        state.tabs[action.itemType] = itemList
    case let action as ItemListAction:
        switch action {
        case let .view(item):
            state.selectedItem = ItemDetails(item)
        case .dismiss(_):
            state.selectedItem = .none
        }
    case let action as CommentFetchAction:
        switch action {
        case .fetch(comments: _):
            state.selectedItem?.fetchingMore = true
        case let .fetched(comments: comments):
            state.selectedItem?.comments += comments
            state.selectedItem?.fetchingMore = false
        }
    default:
        break
    }

    return state
}
