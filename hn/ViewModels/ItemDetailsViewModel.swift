struct ItemDetailsViewModel {
    let item: Item
    let comments: [Item]
    let fetching: FetchState?
    let hasMoreItems: Bool
    let headerOffset = 1
    let totalComments: Int

    init(details: ItemDetails) {
        item = details.item
        fetching = details.fetching
        comments = [details.item] + details.comments
        hasMoreItems = details.fetching != .started && (details.item.descendants ?? 0) > details.comments.count
        totalComments = max((details.item.descendants ?? 0), details.comments.count)
    }
}
