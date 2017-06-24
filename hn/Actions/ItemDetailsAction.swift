import Foundation
import ReSwift
import Alamofire
import UIKit

enum CommentFetchAction: Action {
    case fetch(comments: [Int])
    case fetched(comments: [Item])
}

func fetchComments(state: AppState, store: Store<AppState>) -> Action? {
    guard let state = state.selectedItem else {
        return .none
    }

    fetchSiblings(forItem: state.item) { items in
        DispatchQueue.main.async {
            store.dispatch(CommentFetchAction.fetched(comments: items))
        }
    }

    return CommentFetchAction.fetch(comments: [state.item.id])
}

private func fetchSiblings(forItem item: Item, onCompletion: @escaping ([Item]) -> Void) {
    (item.kids ?? []).flatMap(async: fetchSiblings, withResult: onCompletion)
}

private func fetchSiblings(forItem id: Int, onCompletion: @escaping ([Item]) -> Void) {
    fetch(Endpoint.item(id)) { (item: Result<Item>) in
        guard case let .success(item) = item else {
            onCompletion([])
            return
        }

        (item.kids ?? []).flatMap(async: fetchSiblings) { items in
            onCompletion([item] + items)
        }
    }
}
