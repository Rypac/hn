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

    fetchSiblings(forItem: state.item.id) { items in
        let comments = Array(items.suffix(from: 1))
        store.dispatch(CommentFetchAction.fetched(comments: comments))
    }

    return CommentFetchAction.fetch(comments: [])
}

private func fetchSiblings(forItem id: Int, onCompletion: @escaping ([Item]) -> Void) {
    fetch(.item(id)) { (item: Result<Item>) in
        var kids = [Item]()
        let requestGroup = DispatchGroup()
        item.withValue { value in
            kids.append(value)
            value.kids?.forEach { kid in
                requestGroup.enter()
                fetchSiblings(forItem: kid) { items in
                    kids += items
                    requestGroup.leave()
                }
            }
        }
        requestGroup.notify(queue: .main) {
            onCompletion(kids)
        }
    }
}
