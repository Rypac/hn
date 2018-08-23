import PromiseKit
import ReSwift

struct CommentListFetchAction: Action {
  let state: AsyncRequestState<(Post, [Comment])>

  init(_ state: AsyncRequestState<(Post, [Comment])>) {
    self.state = state
  }
}

enum CommentListNavigationAction: Action {
  case view(post: Post)
  case dismiss
}

enum CommentItemAction: Action {
  case collapse(Comment)
  case expand(Comment)
}

func fetchComments(_ request: @escaping (Id) -> Promise<Item>) -> (Id) -> AsyncActionCreator<AppState, Void> {
  return { id in { _, store in
    firstly {
      store.dispatch(CommentListFetchAction(.request))
    }.then {
      fetchSiblingsForId(with: request)(id)
    }.then(on: DispatchQueue.global(qos: .userInitiated)) { item in
      try item.extractPostAndComments().or(throw: "Invalid post and comments")
    }.then { result in
      store.dispatch(CommentListFetchAction(.success(result: result)))
    }.recover { error in
      store.dispatch(CommentListFetchAction(.error(error: error)))
    }
  } }
}

func fetchSiblingsForId(with request: @escaping (Id) -> Promise<Item>) -> (Id) -> Promise<Item> {
  let resolveChild = { (item: Reference<Item>) -> Promise<Item> in
    switch item {
    case let .id(id): return fetchSiblingsForId(with: request)(id)
    case let .value(item): return Promise(value: item)
    }
  }
  return { id in
    request(id).then { item in
      when(fulfilled: item.kids.map(resolveChild))
        .then { items in item.with(kids: items) }
        .recover { _ in item }
    }
  }
}
