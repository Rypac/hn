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
    case items(AsyncRequestState<[Item]>)
}

enum ItemListNavigationAction: Action {
    case view(Post)
    case viewOriginal(Post)
    case dismiss(Post)
    case dismissOriginal
}

func fetchItems(_ type: ItemType) -> AsyncActionCreator<AppState, Void> {
    return { state, store in
        guard let itemList = state.tabs[type] else {
            return .none
        }
        let action = itemList.ids.isEmpty ? fetchItemList : fetchNextItemBatch
        return action(type)(state, store)
    }
}

func fetchItemList(_ type: ItemType) -> AsyncActionCreator<AppState, Void> {
    return { _, store in
        return firstly {
            store.dispatch(ItemListFetchAction(type, .ids(.request)))
        }.then {
            Firebase.fetch(stories: type)
        }.then { ids in
            store.dispatch(ItemListFetchAction(type, .ids(.success(result: ids))))
        }.catch { error in
            store.dispatch(ItemListFetchAction(type, .ids(.error(error: error))))
        }
    }
}

func fetchNextItemBatch(_ type: ItemType) -> AsyncActionCreator<AppState, Void> {
    return { state, store in
        guard
            let state = state.tabs[type],
            state.ids.count > state.posts.count
        else {
            return .none
        }

        let start = state.posts.count
        let end = start + min(16, state.ids.count - state.posts.count)
        let ids = Array(state.ids[start..<end])

        return firstly {
            store.dispatch(ItemListFetchAction(type, .items(.request)))
        }.then {
            when(fulfilled: ids.map(Firebase.fetch(item:)))
        }.then { items in
            store.dispatch(ItemListFetchAction(type, .items(.success(result: items))))
        }.catch { error in
            store.dispatch(ItemListFetchAction(type, .items(.error(error: error))))
        }
    }
}

func routeTo(_ post: Post, from viewController: UIViewController?) {
    guard let navigationController = viewController?.navigationController else {
        return
    }

    navigationController.pushViewController(ItemDetailsViewController(post), animated: true)
    store.dispatch(ItemListNavigationAction.view(post))
}

func routeTo(original post: Post, from viewController: UIViewController?) {
    guard
        let controller = viewController,
        let content = post.content.details,
        let urlString = content.url,
        let url = URL(string: urlString)
    else {
        return
    }

    let safari = SFSafariViewController(url: url)
    safari.delegate = controller as? SFSafariViewControllerDelegate
    controller.present(safari, animated: true, completion: nil)
    store.dispatch(ItemListNavigationAction.viewOriginal(post))
}
