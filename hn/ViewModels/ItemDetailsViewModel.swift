struct PostResponse {
    let comment: Comment
    let depth: Int
}

struct ItemDetailsViewModel {
    enum Section: Int {
        case parent = 0
        case comments = 1
    }

    let title: String
    let parent: Post
    let comments: [PostResponse]
    let fetching: FetchState?
    let hasMoreComments: Bool

    init(details: ItemDetails) {
        let descendants = details.item.descendants
        let allComments = details.item.flattenComments()
        let visibleComments = allComments.filter { !$0.0.isOrphaned }
        let commentCount = allComments.isEmpty ? descendants : visibleComments.count

        title = "\(commentCount) Comments"
        parent = details.item
        fetching = details.fetching
        comments = visibleComments.map(PostResponse.init(comment:depth:))
        hasMoreComments = details.fetching == .none ||
            details.fetching == .finished && descendants > allComments.count
    }
}

extension ItemDetailsViewModel: Equatable {
    static func == (_ lhs: ItemDetailsViewModel, _ rhs: ItemDetailsViewModel) -> Bool {
        return lhs.fetching == rhs.fetching &&
            lhs.hasMoreComments == rhs.hasMoreComments &&
            lhs.parent == rhs.parent &&
            lhs.comments == rhs.comments
    }
}

extension PostResponse: Equatable {
    static func == (_ lhs: PostResponse, _ rhs: PostResponse) -> Bool {
        return lhs.depth == rhs.depth && lhs.comment == rhs.comment
    }
}
