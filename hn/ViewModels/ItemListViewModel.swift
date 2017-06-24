struct ItemListViewModel {
    let items: [Item]
    let fetching: ContainerFetchState?
    let hasMoreItems: Bool
    let selectedItem: ItemDetails?

    init() {
        self.init(list: ItemList(), details: .none)
    }

    init(list: ItemList, details: ItemDetails?) {
        fetching = list.fetching
        items = list.items
        hasMoreItems = list.ids.isEmpty || list.items.count < list.ids.count
        selectedItem = details
    }
}
