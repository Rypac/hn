import Foundation
import ReSwift

enum CommentFetchAction: Action {
    case fetch(comments: [Int])
    case fetched(comments: [Item])
}

func fetchComments(state: AppState, store: Store<AppState>) -> Action? {
    guard let state = state.selectedItem else {
        return .none
    }

    fetchSiblingsForItem(with: fetch)(state.item) { items in
        DispatchQueue.main.async {
            store.dispatch(CommentFetchAction.fetched(comments: items))
        }
    }

    return CommentFetchAction.fetch(comments: [state.item.id])
}

typealias FetchItemsBy<T> = (_ value: T, _ onCompletion: @escaping ([Item]) -> Void) -> Void

func fetchSiblingsForItem(with request: @escaping ApiRequest<Item>) -> FetchItemsBy<Item> {
    return { item, onCompletion in
        let siblings = item.kids ?? []
        siblings.flatMap(async: fetchSiblingsForId(with: request), withResult: onCompletion)
    }
}

func fetchSiblingsForId(with request: @escaping ApiRequest<Item>) -> FetchItemsBy<Int> {
    return { id, onCompletion in
        request(Endpoint.item(id)) { item in
            guard case let .success(item) = item else {
                onCompletion([])
                return
            }

            let siblings = item.kids ?? []
            siblings.flatMap(async: fetchSiblingsForId(with: request)) { items in
                onCompletion([item] + items)
            }
        }
    }
}
