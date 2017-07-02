struct CommentItem {
    let item: Item
    let depth: Int
}

struct ItemDetailsViewModel {
    let title: String
    let item: Item
    let comments: [CommentItem]
    let fetching: FetchState?
    let hasMoreItems: Bool
    let headerOffset = 1

    init(details: ItemDetails) {
        let descendants = details.item.descendants ?? 0
        let deletedOrphan = { (item: Item) in item.deleted && item.kids.isEmpty }
        let allComments = details.item.flatten()
        let visibleComments = allComments.filter { !deletedOrphan($0.item) }
        let commentCount = visibleComments.count > 1
            ? visibleComments.count - 1
            : descendants

        title = "\(commentCount) Comments"
        item = details.item
        fetching = details.fetching
        comments = visibleComments
        hasMoreItems = details.fetching == .none ||
            details.fetching == .finished && descendants > allComments.count
    }
}

extension Item {
    func flatten(depth: Int = 0) -> [CommentItem] {
        let kids = self.kids.flatMap { kid -> Item? in
            switch kid {
            case .value(let item): return item
            case .id: return .none
            }
        }
        return [CommentItem(item: self, depth: depth)] + kids.flatMap { $0.flatten(depth: depth + 1) }
    }
}

extension CommentItem: Equatable {
    static func == (_ lhs: CommentItem, _ rhs: CommentItem) -> Bool {
        return lhs.item == rhs.item && lhs.depth == rhs.depth
    }
}

extension ItemDetailsViewModel: Equatable {
    static func == (_ lhs: ItemDetailsViewModel, _ rhs: ItemDetailsViewModel) -> Bool {
        return lhs.fetching == rhs.fetching &&
            lhs.hasMoreItems == rhs.hasMoreItems &&
            lhs.comments == rhs.comments
    }
}
