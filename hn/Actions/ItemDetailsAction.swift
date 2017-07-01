import PromiseKit
import ReSwift

enum CommentFetchAction: Action {
    case fetch(item: Item)
    case fetched(item: Item)
}

func fetchComments(forItem item: Item) -> Action {
    firstly {
        fetchSiblingsForId(with: Algolia.fetch(item:))(item.id)
    }.then { item in
        store.dispatch(CommentFetchAction.fetched(item: item))
    }.catch { error in
        print("Failed to fetch comments for item \(item.id): \(error)")
    }
    return CommentFetchAction.fetch(item: item)
}

func fetchSiblingsForId(with request: @escaping (Int) -> Promise<Item>) -> (Int) -> Promise<Item> {
    let fetchChild = { (item: Reference<Item>) -> Promise<Item> in
        switch item {
        case let .id(id): return fetchSiblingsForId(with: request)(id)
        case let .value(item): return Promise(value: item)
        }
    }
    return { id in
        request(id).then { item in
            when(fulfilled: item.kids.map(fetchChild))
                .then { items in item.with(kids: items) }
                .recover { _ in item }
        }
    }
}
