import PromiseKit
import ReSwift

enum CommentListFetchAction: Action {
    case fetch(post: Post)
    case fetched(item: Item)
}

enum CommentListNavigationAction: Action {
    case view(post: Post)
    case dismiss
}

enum CommentItemAction: Action {
    case collapse(Comment)
    case expand(Comment)
}

func fetchComments(forPost post: Post) -> Promise<Void> {
    return firstly {
        store.dispatch(CommentListFetchAction.fetch(post: post))
    }.then {
        fetchSiblingsForId(with: Algolia.fetch(item:))(post.id)
    }.then { item in
        store.dispatch(CommentListFetchAction.fetched(item: item))
    }.recover { error in
        print("Failed to fetch comments for item \(post.id): \(error)")
    }
}

func fetchSiblingsForId(with request: @escaping (Int) -> Promise<Item>) -> (Int) -> Promise<Item> {
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
