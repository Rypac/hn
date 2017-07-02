struct ItemListViewModel {
    enum Section: Int {
        case items = 0
    }

    let items: [Item]
    let fetching: ContainerFetchState?
    let hasMoreItems: Bool
    let selectedItem: ItemDetails?

    init(list: ItemList = ItemList(), details: ItemDetails? = .none) {
        fetching = list.fetching
        items = list.items
        hasMoreItems = list.ids.isEmpty || list.items.count < list.ids.count
        selectedItem = details
    }
}
