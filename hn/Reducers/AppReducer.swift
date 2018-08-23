// swiftlint:disable cyclomatic_complexity function_body_length
import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
  var state = state ?? defaultAppState

  switch action {
  case let action as ItemListFetchAction:
    guard var itemList = state.tabs[action.itemType] else {
      return state
    }
    switch action.state {
    case let .ids(fetchState):
      switch fetchState {
      case .request:
        itemList.ids = []
        itemList.fetching = .list(.started)
      case let .success(result: ids):
        itemList.ids = ids
        itemList.posts = []
        itemList.fetching = .list(.finished)
      case let .error(error: error):
        print("Error fetching item ids: \(error)")
        itemList.fetching = .list(.finished)
      default:
        break
      }
    case let .items(fetchState):
      switch fetchState {
      case .request:
        itemList.fetching = .items(.started)
      case let .success(result: posts):
        itemList.posts += posts
        itemList.fetching = .items(.finished)
      case let .error(error: error):
        print("Error fetching items: \(error)")
        itemList.fetching = .items(.finished)
      default:
        break
      }
    }
    state.tabs[action.itemType] = itemList

  case let action as ItemListNavigationAction:
    switch action {
    case let .view(post):
      state.selectedItem = ItemDetails(post)
      state.repository.fetchItem = Algolia().item(id:)
    case .dismiss:
      state.selectedItem = .none
      state.repository.fetchItem = Firebase().item(id:)
    default:
      break
    }

  case let action as CommentListFetchAction:
    switch action.state {
    case .request:
      state.selectedItem?.fetching = .started
    case let .success(result: (post, comments)):
      state.selectedItem?.post = post
      state.selectedItem?.comments = comments
      state.selectedItem?.fetching = .finished
    case let .error(error: error):
      print("Error fetching item: \(error)")
      state.selectedItem?.fetching = .finished
    default:
      break
    }

  case let action as CommentItemAction:
    let indexOf = { (comment: Comment) in
      state.selectedItem?.comments.index(where: { $0.id == comment.id })
    }
    switch action {
    case let .collapse(comment):
      if let index = indexOf(comment) {
        state.selectedItem?.comments[index].actions.collapsed = true
      }
    case let .expand(comment):
      if let index = indexOf(comment) {
        state.selectedItem?.comments[index].actions.collapsed = false
      }
    }

  default:
    break
  }

  return state
}
