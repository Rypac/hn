struct ItemDetailsViewModel {
    enum Section: Int {
        case parent = 0
        case comments = 1
    }

    let title: String
    let parent: Post
    let comments: [Comment]
    let fetching: FetchState?
    let hasMoreComments: Bool

    init(details: ItemDetails) {
        let descendants = details.post.descendants
        let allComments = details.comments
        let visibleComments = allComments.filter { !$0.isOrphaned }
        let commentCount = allComments.isEmpty ? descendants : visibleComments.count

        title = "\(commentCount) Comments"
        parent = details.post
        fetching = details.fetching
        comments = visibleComments
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
