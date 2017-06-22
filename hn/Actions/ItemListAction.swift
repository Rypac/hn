import Foundation
import ReSwift
import Alamofire
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
    case dismiss(Item)
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
        fetch(type.endpoint) { (ids: [Int]) in
            DispatchQueue.main.async {
                store.dispatch(FetchAction(itemType: type, action: .fetchedIds(ids)))
                store.dispatch(fetchNextItemBatch(type))
            }
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

        ids.forAll(async: { id, onCompletion in
            fetch(.item(id)) { (item: Result<Item>) in
                onCompletion(item.value)
            }
        }, after: { items in
            store.dispatch(FetchAction(itemType: type, action: .fetchedItems(items)))
        })

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
