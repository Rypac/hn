import PromiseKit
import ReSwift
import SafariServices
import UIKit


struct FetchAction: Action {
    let itemType: ItemType
    let action: ItemFetchState
}

enum ItemFetchState {
    case fetch
    case fetchedIds([Int])
    case fetchItems(ids: [Int])
    case fetchedItems([Item])
}

enum ItemListAction: Action {
    case view(Item)
    case viewOriginal(Item)
    case dismiss(Item)
    case dismissOriginal
}

extension ItemType {
    var endpoint: Endpoint {
        switch self {
        case .topStories: return .topStories
        case .newStories: return .newStories
        case .bestStories: return .bestStories
        case .showHN: return .showHN
        case .askHN: return .askHN
        case .jobs: return .jobs
        case .updates: return .updates
        }
    }
}

typealias ActionCreator<T: StateType> = (T, Store<T>) -> Action?

func fetchItems(_ type: ItemType) -> ActionCreator<AppState> {
    return { state, store in
        guard let itemList = state.tabs[type] else {
            return .none
        }
        let action = itemList.ids.isEmpty ? fetchItemList : fetchNextItemBatch
        return action(type)(state, store)
    }
}

func fetchItemList(_ type: ItemType) -> ActionCreator<AppState> {
    return { state, store in
        fetch(type.endpoint).then { (ids: [Int]) in
            store.dispatch(FetchAction(itemType: type, action: .fetchedIds(ids)))
        }.then {
            store.dispatch(fetchNextItemBatch(type))
        }.catch { error in
            print("Failed to fetch \(type) list: \(error)")
        }
        return FetchAction(itemType: type, action: .fetch)
    }
}

func fetchNextItemBatch(_ type: ItemType) -> ActionCreator<AppState> {
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

        when(fulfilled: ids.map { fetch(Endpoint.item($0)) }).then { items in
            store.dispatch(FetchAction(itemType: type, action: .fetchedItems(items)))
        }.catch { error in
            print("Failed to fetch items: \(error)")
        }

        return FetchAction(itemType: type, action: .fetchItems(ids: ids))
    }
}

func routeTo(_ item: Item, from viewController: UIViewController?) -> ActionCreator<AppState> {
    return { state, store in
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(ItemDetailsViewController(item), animated: true)
            return ItemListAction.view(item)
        }
        return .none
    }
}

func routeTo(original item: Item, from viewController: UIViewController?) -> ActionCreator<AppState> {
    return { state, store in
        if
            let controller = viewController,
            let urlString = item.url,
            let url = URL(string: urlString)
        {
            let safari = SFSafariViewController(url: url)
            safari.delegate = controller as? SFSafariViewControllerDelegate
            controller.present(safari, animated: true, completion: nil)
            return ItemListAction.viewOriginal(item)
        }
        return .none
    }
}
