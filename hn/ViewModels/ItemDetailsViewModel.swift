import IGListKit

class CommentViewModel {
    let comment: Comment

    init(_ comment: Comment) {
        self.comment = comment
    }
}

extension CommentViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return NSNumber(value: comment.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? CommentViewModel else {
            return false
        }
        return comment.depth == object.comment.depth &&
            comment.actions == object.comment.actions &&
            comment.content == object.comment.content
    }
}

class ItemDetailsViewModel {
    enum Section: Int {
        case parent = 0
        case comments = 1
    }

    let title: String
    let parent: Post
    let fetching: FetchState?
    let hasMoreComments: Bool
    fileprivate let allComments: [Comment]

    lazy var comments: [CommentViewModel] = self.allComments.transformVisible()

    init(details: ItemDetails) {
        title = "\(max(details.post.descendants, details.comments.count)) Comments"
        parent = details.post
        fetching = details.fetching
        allComments = details.comments
        hasMoreComments = details.fetching == .none ||
            details.fetching == .finished && details.post.descendants > details.comments.count
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
