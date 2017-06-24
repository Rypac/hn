struct ItemDetailsViewModel {
    let item: Item
    let comments: [Item]
    let fetching: FetchState?
    let hasMoreItems: Bool

    init(details: ItemDetails) {
        item = details.item
        fetching = details.fetching
        comments = details.comments
        hasMoreItems = details.fetching != .started && (details.item.descendants ?? 0) > details.comments.count
    }
}
