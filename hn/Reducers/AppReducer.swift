// swiftlint:disable cyclomatic_complexity function_body_length
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
    case let action as ItemListFetchAction:
        guard var itemList = state.tabs[action.itemType] else {
            return state
        }
        switch action.action {
        case .fetch:
            itemList.ids = []
            itemList.fetching = .list(.started)
        case let .fetchedIds(ids):
            itemList.ids = ids
            itemList.posts = []
            itemList.fetching = .list(.finished)
        case .fetchItems:
            itemList.fetching = .items(.started)
        case let .fetchedItems(items):
            itemList.posts += items.flatMap(Post.init(fromItem:))
            itemList.fetching = .items(.finished)
        }
        state.tabs[action.itemType] = itemList
    case let action as ItemListNavigationAction:
        switch action {
        case let .view(post):
            state.selectedItem = ItemDetails(post)
        case let .viewOriginal(post):
            state.selectedItem = ItemDetails(post)
        case .dismiss:
            state.selectedItem = .none
        case .dismissOriginal:
            state.selectedItem = .none
        }
    case let action as CommentListFetchAction:
        switch action {
        case .fetch:
            state.selectedItem?.fetching = .started
        case let .fetched(item: item):
            if let (post, comments) = item.extractPostAndComments() {
                state.selectedItem?.post = post
                state.selectedItem?.comments = comments
            }
            state.selectedItem?.fetching = .finished
        }
    case let action as CommentItemAction:
        switch action {
        case let .collapse(comment):
            if let index = state.selectedItem?.comments.index(where: { $0.id == comment.id }) {
                state.selectedItem?.comments[index].actions.collapsed = !comment.actions.collapsed
            }
        }
    default:
        break
    }

    return state
}
