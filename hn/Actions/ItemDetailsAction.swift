import Foundation
import ReSwift
import Alamofire
import UIKit

enum CommentFetchAction: Action {
    case fetch(comments: [Int])
    case fetched(comments: [Item])
}

func fetchNextCommentBatch(state: AppState, store: Store<AppState>) -> Action? {
    guard
        let state = state.selectedItem,
        let kids = state.item.descendants,
        kids > state.comments.count
    else {
        return .none
    }

    fetchSiblings(forItem: state.item) { items in
        store.dispatch(CommentFetchAction.fetched(comments: items))
    }

    return CommentFetchAction.fetch(comments: [state.item.id])
}

private func fetchSiblings(forItem item: Item, onCompletion: @escaping ([Item]) -> Void) {
    forAll(item.kids ?? [], performAsync: fetchSiblings, after: onCompletion)
}

private func fetchSiblings(forItem id: Int, onCompletion: @escaping ([Item]) -> Void) {
    fetch(.item(id)) { (item: Result<Item>) in
        guard case let .success(item) = item else {
            onCompletion([])
            return
        }

        forAll(item.kids ?? [], performAsync: fetchSiblings) { items in
            onCompletion([item] + items)
        }
    }
}

private func forAll<T, U>(_ sequence: [T], performAsync: (T, @escaping ([U]) -> Void) -> Void, after: @escaping ([U]) -> Void) {
    var values = [U]()
    let requestGroup = DispatchGroup()
    sequence.forEach { value in
        requestGroup.enter()
        performAsync(value) { asyncValue in
            values += asyncValue
            requestGroup.leave()
        }
    }
    requestGroup.notify(queue: .main) {
        after(values)
    }
}
