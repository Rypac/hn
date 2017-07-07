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
        guard self !== object else {
            return true
        }
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

    let parent: Post
    let fetching: FetchState?
    let hasMoreComments: Bool
    fileprivate let allComments: [Comment]

    lazy var title: String =
        "\(self.allComments.isEmpty ? self.parent.descendants : self.comments.count) Comments"
    lazy var comments: [CommentViewModel] =
        self.allComments.lazy
            .filter { !$0.isOrphaned }
            .dropResponses(where: { $0.actions.collapsed })
            .map(CommentViewModel.init)

    init(details: ItemDetails) {
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
    func dropResponses(where shouldDrop: (Comment) -> Bool) -> Array {
        return Array(sliced.dropResponses(when: shouldDrop))
    }
}

extension ArraySlice where Iterator.Element == Comment {
    func dropResponses(when shouldDrop: (Comment) -> Bool) -> ArraySlice {
        guard let comment = first else {
            return self
        }
        let tail = dropFirst()
        let remaining = shouldDrop(comment)
            ? tail.drop(while: { $0.depth > comment.depth })
            : tail
        return prefix(upTo: tail.startIndex) + remaining.dropResponses(when: shouldDrop)
    }
}
