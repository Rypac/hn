import Foundation

final class ItemListViewModel {
  let itemType: ItemType
  let fetching: ContainerFetchState?
  let hasMoreItems: Bool

  let requestItemList: AsyncActionCreator<AppState, Void>
  let requestNextItemBatch: AsyncActionCreator<AppState, Void>

  fileprivate let allPosts: [Post]

  lazy var posts: [PostViewModel] = self.allPosts.map(PostViewModel.init)

  init(type: ItemType, list: ItemList, repo: Repository) {
    itemType = type
    fetching = list.fetching
    allPosts = list.posts
    hasMoreItems = list.fetching == .none ||
      list.fetching == .list(.finished) ||
      (list.fetching == .items(.finished) && list.posts.count < list.ids.count)

    requestItemList = fetchItemList(repo.fetchItems)(type)
    requestNextItemBatch = fetchNextItemBatch(repo.fetchItem)(type)
  }
}

extension ItemListViewModel: Equatable {
  static func == (_ lhs: ItemListViewModel, _ rhs: ItemListViewModel) -> Bool {
    return lhs.itemType == rhs.itemType &&
      lhs.fetching == rhs.fetching &&
      lhs.hasMoreItems == rhs.hasMoreItems &&
      lhs.allPosts == rhs.allPosts
  }
}
