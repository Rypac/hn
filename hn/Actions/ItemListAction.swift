import PromiseKit
import ReSwift
import SafariServices
import UIKit

struct ItemListFetchAction: Action {
    let itemType: ItemType
    let state: ItemFetchState

    init(_ itemType: ItemType, _ state: ItemFetchState) {
        self.itemType = itemType
        self.state = state
    }
}

enum ItemFetchState {
    case ids(AsyncRequestState<[Id]>)
    case items(AsyncRequestState<[Post]>)
}

enum ItemListNavigationAction: Action {
    case view(Post)
    case viewOriginal(Post)
    case dismiss(Post)
    case dismissOriginal
}

typealias StoryListActionCreator = (ItemType) -> AsyncActionCreator<AppState, Void>

func fetchItemList(_ request: @escaping (ItemType) -> Promise<[Id]>) -> StoryListActionCreator {
    return { type in { _, store in
        firstly {
            store.dispatch(ItemListFetchAction(type, .ids(.request)))
        }.then {
            request(type)
        }.then { ids in
            store.dispatch(ItemListFetchAction(type, .ids(.success(result: ids))))
        }.recover { error in
            store.dispatch(ItemListFetchAction(type, .ids(.error(error: error))))
        } }
    }
}

func fetchNextItemBatch(_ request: @escaping (Id) -> Promise<Item>) -> StoryListActionCreator {
    return { type in { state, store in
        guard
            let itemList = state.tabs[type],
            itemList.ids.count > itemList.posts.count
        else {
            return .none
        }

        let start = itemList.posts.count
        let end = start + min(16, itemList.ids.count - itemList.posts.count)
        let ids = itemList.ids[start..<end]

        return firstly {
            store.dispatch(ItemListFetchAction(type, .items(.request)))
        }.then {
            when(fulfilled: ids.map(request))
        }.then { items in
            items.flatMap(Post.init(fromItem:))
        }.then { posts in
            store.dispatch(ItemListFetchAction(type, .items(.success(result: posts))))
        }.recover { error in
            store.dispatch(ItemListFetchAction(type, .items(.error(error: error))))
        }
    } }
}

func routeTo(_ post: Post, from viewController: UIViewController) -> Store<AppState>.ActionCreator {
    return { state, _ in
        guard let navigationController = viewController.navigationController else {
            return .none
        }

        let controller = ItemDetailsViewController(
            state: ItemDetailsViewModel(details: ItemDetails(post), repo: state.repository))
        navigationController.pushViewController(controller, animated: true)
        return ItemListNavigationAction.view(post)
    }
}

func routeTo(original post: Post, from viewController: UIViewController) -> Action? {
    guard
        let content = post.content.details,
        let urlString = content.url,
        let url = URL(string: urlString)
    else {
        return .none
    }

    let safari = SFSafariViewController(url: url)
    safari.delegate = viewController as? SFSafariViewControllerDelegate
    viewController.present(safari, animated: true, completion: nil)
    return ItemListNavigationAction.viewOriginal(post)
}
