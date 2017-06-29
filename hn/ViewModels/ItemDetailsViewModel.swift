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
        let commentItems = details.item.flatten()
        let totalComments = max(details.item.descendants ?? 0, commentItems.count - 1)
        title = "\(totalComments) comments"
        item = details.item
        fetching = details.fetching
        comments = commentItems
        hasMoreItems = details.fetching != .started && (details.item.descendants ?? 0) > commentItems.count - 1
    }
}

extension Item {
    func flatten(depth: Int = 0) -> [CommentItem] {
        let kids = self.kids.flatMap { kid -> Item? in
            switch kid {
            case let .value(item): return item
            default: return .none
            }
        }
        return [CommentItem(item: self, depth: depth)] + kids.flatMap { $0.flatten(depth: depth + 1) }
    }
}
