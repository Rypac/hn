import PromiseKit
import ReSwift
import SafariServices
import UIKit

struct ItemListFetchAction: Action {
    let itemType: ItemType
    let action: ItemFetchState
}

enum ItemFetchState {
    case fetch
    case fetchedIds([Int])
    case fetchItems(ids: [Int])
    case fetchedItems([Item])
}

enum ItemListNavigationAction: Action {
    case view(Post)
    case viewOriginal(Post)
    case dismiss(Post)
    case dismissOriginal
}

func fetchItems(_ type: ItemType) -> Store<AppState>.ActionCreator {
    return { state, store in
        guard let itemList = state.tabs[type] else {
            return .none
        }
        return itemList.ids.isEmpty
            ? fetchItemList(type)
            : fetchNextItemBatch(type)(state, store)
    }
}

func fetchItemList(_ type: ItemType) -> Action {
    firstly {
        Firebase.fetch(stories: type)
    }.then { ids in
        store.dispatch(ItemListFetchAction(itemType: type, action: .fetchedIds(ids)))
    }.then {
        store.dispatch(fetchNextItemBatch(type))
    }.catch { error in
        print("Failed to fetch \(type) list: \(error)")
    }
    return ItemListFetchAction(itemType: type, action: .fetch)
}

func fetchNextItemBatch(_ type: ItemType) -> Store<AppState>.ActionCreator {
    return { state, store in
        guard
            let state = state.tabs[type],
            state.ids.count > state.items.count
        else {
            return .none
        }

        let start = state.items.count
        let end = start + min(16, state.ids.count - state.items.count)
        let ids = Array(state.ids[start..<end])

        firstly {
            when(fulfilled: ids.map(Firebase.fetch(item:)))
        }.then { items in
            store.dispatch(ItemListFetchAction(itemType: type, action: .fetchedItems(items)))
        }.catch { error in
            print("Failed to fetch items: \(error)")
        }
        return ItemListFetchAction(itemType: type, action: .fetchItems(ids: ids))
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
