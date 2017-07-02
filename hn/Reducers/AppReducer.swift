// swiftlint:disable cyclomatic_complexity
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
            itemList.ids = []
            itemList.fetching = .list(.started)
        case let .fetchedIds(ids):
            itemList.ids = ids
            itemList.items = []
            itemList.fetching = .list(.finished)
        case .fetchItems:
            itemList.fetching = .items(.started)
        case let .fetchedItems(items):
            itemList.items += items
            itemList.fetching = .items(.finished)
        }
        state.tabs[action.itemType] = itemList
    case let action as ItemListAction:
        switch action {
        case let .view(item):
            state.selectedItem = ItemDetails(item)
        case let .viewOriginal(item):
            state.selectedItem = ItemDetails(item)
        case .dismiss:
            state.selectedItem = .none
        case .dismissOriginal:
            state.selectedItem = .none
        }
    case let action as CommentFetchAction:
        switch action {
        case .fetch:
            state.selectedItem?.fetching = .started
        case let .fetched(item: item):
            state.selectedItem?.item = item
            state.selectedItem?.fetching = .finished
        }
    default:
        break
    }

    return state
}
