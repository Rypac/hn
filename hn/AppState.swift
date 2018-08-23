import PromiseKit
import ReSwift

struct AppState: StateType {
  var repository: Repository
  var tabs = [ItemType: ItemList]()
  var selectedTab: ItemType?
  var selectedItem: ItemDetails?
}

struct Repository {
  var fetchItems: (ItemType) -> Promise<[Id]>
  var fetchItem: (Id) -> Promise<Item>
}

struct ItemList {
  var ids = [Id]()
  var posts = [Post]()
  var fetching: ContainerFetchState? = .none
}

struct ItemDetails {
  var post: Post
  var comments: [Comment] = []
  var fetching: FetchState? = .none

  init(_ post: Post) {
    self.post = post
  }
}

enum ContainerFetchState {
  case list(FetchState)
  case items(FetchState)
}

enum FetchState {
  case started
  case finished
}

struct User {
  let username: String
  let karma: Int
  let created: Int
  let id: Id?
  let about: String?
  let delay: Int?
}

extension ContainerFetchState: Equatable {
  static func == (_ lhs: ContainerFetchState, _ rhs: ContainerFetchState) -> Bool {
    switch (lhs, rhs) {
    case let (.list(lhs), .list(rhs)):
      return lhs == rhs
    case let (.items(lhs), .items(rhs)):
      return lhs == rhs
    case (.list, .items), (.items, .list):
      return false
    }
  }
}
