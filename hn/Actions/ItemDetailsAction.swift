import PromiseKit
import ReSwift

struct CommentListFetchAction: Action {
    let state: AsyncRequestState<Item>

    init(_ state: AsyncRequestState<Item>) {
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

func fetchComments(forPost post: Id) -> AsyncActionCreator<AppState, Void> {
    return { _, store in
        return firstly {
            store.dispatch(CommentListFetchAction(.request))
        }.then {
            fetchSiblingsForId(with: Algolia.fetch(item:))(post)
        }.then { item in
            store.dispatch(CommentListFetchAction(.success(result: item)))
        }.catch { error in
            store.dispatch(CommentListFetchAction(.error(error: error)))
        }
    }
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
