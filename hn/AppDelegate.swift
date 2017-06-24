import UIKit
import AlamofireNetworkActivityIndicator
import ReSwift

let store = Store<AppState>(
    reducer: appReducer,
    state: AppState(
        tabs: [
            .topStories: ItemList(),
            .newStories: ItemList(),
            .bestStories: ItemList(),
            .askHN: ItemList(),
            .showHN: ItemList()
        ],
        selectedTab: .none,
        selectedItem: .none))

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
        ) -> Bool {
        NetworkActivityIndicatorManager.shared.isEnabled = true

        let tabController = UITabBarController()
        tabController.setViewControllers(visibleTabs(store.state.tabs), animated: false)
        tabController.selectedIndex = 2
        tabController.tabBar.isTranslucent = false

        let navigationController = UINavigationController(rootViewController: tabController)
        navigationController.navigationBar.isTranslucent = false

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}

func visibleTabs(_ tabs: [ItemType: ItemList]) -> [UIViewController] {
    return tabs.enumerated().map { (index, tab) in
        let controller = ItemListViewController(tab.key)
        controller.tabBarItem = UITabBarItem(title: tab.key.description, image: .none, tag: index)
        return controller
    }
}
