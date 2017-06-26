struct ItemDetailsViewModel {
    let title: String
    let item: Item
    let comments: [Item]
    let fetching: FetchState?
    let hasMoreItems: Bool
    let headerOffset = 1

    init(details: ItemDetails) {
        let totalComments = max((details.item.descendants ?? 0), details.comments.count)
        title = "\(totalComments) comments"
        item = details.item
        fetching = details.fetching
        comments = [details.item] + details.comments
        hasMoreItems = details.fetching != .started && (details.item.descendants ?? 0) > details.comments.count
    }
}