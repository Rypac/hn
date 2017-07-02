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
    let hasMoreItems: Bool

    init(details: ItemDetails) {
        let descendants = details.item.descendants ?? 0
        let deletedOrphan = { (item: Item) in item.deleted && item.kids.isEmpty }
        let allComments = details.item.flatten().dropFirst()
        let visibleComments = allComments.filter { !deletedOrphan($0.item) }
        let commentCount = visibleComments.isEmpty ? descendants : visibleComments.count

        title = "\(commentCount) Comments"
        parent = Comment(item: details.item, depth: 0)
        fetching = details.fetching
        comments = visibleComments
        hasMoreItems = details.fetching == .none ||
            details.fetching == .finished && descendants > allComments.count
    }
}

extension Item {
    func flatten(depth: Int = 0) -> [Comment] {
        let kids = self.kids.flatMap { kid -> Item? in
            switch kid {
            case .value(let item): return item
            case .id: return .none
            }
        }
        return [Comment(item: self, depth: depth)] + kids.flatMap { $0.flatten(depth: depth + 1) }
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
            lhs.hasMoreItems == rhs.hasMoreItems &&
            lhs.parent == rhs.parent &&
            lhs.comments == rhs.comments
    }
}
