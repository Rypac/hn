import Foundation

final class ItemDetailsViewModel {
  enum Section: Int {
    case parent = 0
    case comments = 1
  }

  let title: String
  let parent: Post
  let fetching: FetchState?
  let hasMoreComments: Bool
  let requestComments: AsyncActionCreator<AppState, Void>

  fileprivate let allComments: [Comment]

  lazy var comments: [CommentViewModel] = self.allComments.transformVisible()

  init(details: ItemDetails, repo: Repository) {
    title = "\(max(details.post.descendants, details.comments.count)) Comments"
    parent = details.post
    fetching = details.fetching
    allComments = details.comments
    hasMoreComments = details.fetching == .none ||
      details.fetching == .finished && details.post.descendants > details.comments.count

    requestComments = fetchComments(repo.fetchItem)(details.post.id)
  }
}

extension ItemDetailsViewModel: Equatable {
  static func == (_ lhs: ItemDetailsViewModel, _ rhs: ItemDetailsViewModel) -> Bool {
    return lhs.fetching == rhs.fetching &&
      lhs.hasMoreComments == rhs.hasMoreComments &&
      lhs.parent == rhs.parent &&
      lhs.allComments == rhs.allComments
  }
}

extension Array where Iterator.Element == Comment {
  fileprivate func transformVisible() -> [CommentViewModel] {
    var viewModels: [CommentViewModel] = []

    var index = startIndex
    while index < endIndex {
      let comment = self[index]
      index += 1
      if !comment.isOrphaned {
        viewModels.append(CommentViewModel(comment))
        if comment.actions.collapsed {
          while index < endIndex && self[index].depth > comment.depth {
            index += 1
          }
        }
      }
    }

    return viewModels
  }
}
