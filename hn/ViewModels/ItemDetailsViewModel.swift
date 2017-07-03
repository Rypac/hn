struct Comment {
    let item: Item
    let depth: Int
}

struct ItemDetailsViewModel {
    enum Section: Int {
        case parent = 0
        case comments = 1
    }

    let title: String
    let parent: Comment
    let comments: [Comment]
    let fetching: FetchState?
    let hasMoreComments: Bool

    init(details: ItemDetails) {
        let descendants = details.item.descendants ?? 0
        let deletedOrphan = { (item: Item) in item.deleted && item.kids.isEmpty }
        let allComments = details.item.flattenComments()
        let visibleComments = allComments.filter { !deletedOrphan($0.item) }
        let commentCount = allComments.isEmpty ? descendants : visibleComments.count

        title = "\(commentCount) Comments"
        parent = Comment(item: details.item, depth: 0)
        fetching = details.fetching
        comments = visibleComments
        hasMoreComments = details.fetching == .none ||
            details.fetching == .finished && descendants > allComments.count
    }
}

extension Comment: Equatable {
    static func == (_ lhs: Comment, _ rhs: Comment) -> Bool {
        return lhs.item == rhs.item && lhs.depth == rhs.depth
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
