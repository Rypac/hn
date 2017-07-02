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
        let allComments = details.item.flatten()
        let visibleComments = allComments.filter { !$0.item.deleted }
        title = "\(visibleComments.count - 1) comments"
        item = details.item
        fetching = details.fetching
        comments = visibleComments
        hasMoreItems = details.fetching != .started && (details.item.descendants ?? 0) > allComments.count
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
