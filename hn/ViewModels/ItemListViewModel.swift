import Foundation

final class ItemListViewModel {
    let itemType: ItemType
    let repo: Repository
    let fetching: ContainerFetchState?
    let hasMoreItems: Bool
    let selectedItem: ItemDetails?
    fileprivate let allPosts: [Post]

    lazy var posts: [PostViewModel] = self.allPosts.map(PostViewModel.init)

    init(type: ItemType, list: ItemList, details: ItemDetails?, repo: Repository) {
        self.repo = repo
        itemType = type
        fetching = list.fetching
        allPosts = list.posts
        selectedItem = details
        hasMoreItems = list.fetching == .none ||
            list.fetching == .list(.finished) ||
            (list.fetching == .items(.finished) && list.posts.count < list.ids.count)
    }
}

extension ItemListViewModel: Equatable {
    static func == (_ lhs: ItemListViewModel, _ rhs: ItemListViewModel) -> Bool {
        return lhs.itemType == rhs.itemType &&
            lhs.fetching == rhs.fetching &&
            lhs.hasMoreItems == rhs.hasMoreItems &&
            (
                (lhs.selectedItem == nil && rhs.selectedItem == nil) ||
                (lhs.selectedItem != nil && rhs.selectedItem != nil)
            ) &&
            lhs.allPosts == rhs.allPosts
    }
}
