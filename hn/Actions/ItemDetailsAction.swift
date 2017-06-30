import PromiseKit
import ReSwift

enum CommentFetchAction: Action {
    case fetch(item: Item)
    case fetched(item: Item)
}

func fetchComments(state: AppState, store: Store<AppState>) -> Action? {
    guard let state = state.selectedItem else {
        return .none
    }

    fetchSiblingsForId(with: Firebase.fetch(item:))(state.item.id).then { item in
        store.dispatch(CommentFetchAction.fetched(item: item))
    }.catch { error in
        print("Failed to fetch comments for item \(state.item.id): \(error)")
    }

    return CommentFetchAction.fetch(item: state.item)
}

func fetchSiblingsForId(with request: @escaping (Int) -> Promise<Item>) -> (Int) -> Promise<Item> {
    let fetchSiblings = { (item: Reference<Item>) -> Promise<Item> in
        switch item {
        case let .id(id): return fetchSiblingsForId(with: request)(id)
        case let .value(item): return Promise(value: item)
        }
    }
    return { id in
        request(id).then { item in
            when(fulfilled: item.kids.map(fetchSiblings)).then { items in
                item.with(kids: items)
            }.recover { error in
                item
            }
        }
    }
}
