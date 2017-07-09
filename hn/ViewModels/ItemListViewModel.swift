import IGListKit

class PostViewModel {
    let post: Post

    init(_ post: Post) {
        self.post = post
    }
}

extension PostViewModel: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        return NSNumber(value: post.id)
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? PostViewModel else {
            return false
        }
        return post.actions == object.post.actions &&
            post.content == object.post.content &&
            post.descendants == object.post.descendants
    }
}

class ItemListViewModel {
    let fetching: ContainerFetchState?
    let hasMoreItems: Bool
    let selectedItem: ItemDetails?
    fileprivate let allPosts: [Post]

    lazy var posts: [PostViewModel] = self.allPosts.map(PostViewModel.init)

    init(list: ItemList = ItemList(), details: ItemDetails? = .none) {
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
        return lhs.fetching == rhs.fetching &&
            lhs.hasMoreItems == rhs.hasMoreItems &&
            (
                (lhs.selectedItem == nil && rhs.selectedItem == nil) ||
                (lhs.selectedItem != nil && rhs.selectedItem != nil)
            ) &&
            lhs.allPosts == rhs.allPosts
    }
}
