import AsyncDisplayKit
import ReSwift
import UIKit

let defaultAppState = AppState(
    repository: Repository(
        fetchItems: Firebase.fetch(stories:),
        fetchItem: Firebase.fetch(item:)),
    tabs: [
        .topStories: ItemList(),
        .newStories: ItemList(),
        .bestStories: ItemList(),
        .askHN: ItemList(),
        .showHN: ItemList()
    ],
    selectedTab: .none,
    selectedItem: .none)

let store = Store<AppState>(reducer: appReducer, state: defaultAppState)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        let tabController = ASTabBarController()
        tabController.setViewControllers(visibleTabs(store.state.tabs), animated: false)
        tabController.selectedIndex = 2
        tabController.tabBar.isTranslucent = false

        let navigationController = ASNavigationController(rootViewController: tabController)
        navigationController.navigationBar.isTranslucent = false

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.tintColor = UIColor.Apple.orange
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

func visibleTabs(_ tabs: [ItemType: ItemList]) -> [UIViewController] {
    return tabs.enumerated().map { index, tab in
        let state = store.state!
        let controller = ItemListViewController(
            state: ItemListViewModel(type: tab.key, list: tab.value, repo: state.repository))
        controller.tabBarItem = UITabBarItem(title: tab.key.description, image: tab.key.image, tag: index)
        return controller
    }
}
