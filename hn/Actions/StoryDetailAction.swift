import Foundation
import ReSwift
import Alamofire
import UIKit

enum CommentFetchAction: Action {
    case fetch(comments: [Int])
    case fetched(comments: [Comment])
}

func fetchNextCommentBatch(state: AppState, store: Store<AppState>) -> Action? {
    guard
        let state = state.selectedStory,
        let kids = state.story.kids,
        kids.count > state.comments.count
    else {
        return .none
    }

    let start = state.comments.count
    let end = start + min(16, kids.count - state.comments.count)
    let ids = Array(kids[start..<end])

    let requestGroup = DispatchGroup()
    var comments = [Comment]()
    ids.forEach { id in
        requestGroup.enter()
        fetch(.item(id)) { (comment: Result<Comment>) in
            comment.withValue {
                comments.append($0)
            }
            requestGroup.leave()
        }
    }

    requestGroup.notify(queue: .main) {
        store.dispatch(CommentFetchAction.fetched(comments: comments))
    }

    return CommentFetchAction.fetch(comments: ids)
}
