struct ItemListViewModel {
    enum Section: Int {
        case items = 0
    }

    let posts: [Post]
    let fetching: ContainerFetchState?
    let hasMoreItems: Bool
    let selectedItem: ItemDetails?

    init(list: ItemList = ItemList(), details: ItemDetails? = .none) {
        fetching = list.fetching
        posts = list.posts
        hasMoreItems = list.ids.isEmpty || list.posts.count < list.ids.count
        selectedItem = details
    }
}
