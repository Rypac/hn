import PromiseKit
import ReSwift

enum CommentFetchAction: Action {
    case fetch(comments: [Int])
    case fetched(comments: [Item])
}

func fetchComments(state: AppState, store: Store<AppState>) -> Action? {
    guard let state = state.selectedItem else {
        return .none
    }

    fetchSiblingsForItem(with: fetch)(state.item).then { items in
        store.dispatch(CommentFetchAction.fetched(comments: items))
    }.catch { error in
        print("Failed to fetch comments for item \(state.item.id): \(error)")
    }

    return CommentFetchAction.fetch(comments: [state.item.id])
}

func fetchSiblingsForItem(with request: @escaping ApiRequest<Item>) -> (Item) -> Promise<[Item]> {
    let fetchSiblings = { fetchSiblingsForId(with: request)($0) }
    return { item in
        when(fulfilled: (item.kids ?? []).map(fetchSiblings)).then { items in
            items.flatMap { $0 }
        }
    }
}

func fetchSiblingsForId(with request: @escaping ApiRequest<Item>) -> (Int) -> Promise<[Item]> {
    let fetchSiblings = { fetchSiblingsForId(with: request)($0) }
    return { id in
        request(Endpoint.item(id)).then { item in
            when(fulfilled: (item.kids ?? []).map(fetchSiblings)).then { items in
                [item] + items.flatMap { $0 }
            }
        }.recover { _ in [] }
    }
}
