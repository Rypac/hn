import UIKit
import ReSwift

let store = Store<AppState>(
    reducer: appReducer,
    state: AppState(
        tabs: [
            .topStories: StoryList(),
            .newStories: StoryList(),
            .bestStories: StoryList(),
            .askHN: StoryList(),
            .showHN: StoryList()
        ],
        selectedTab: .none))

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UINavigationControllerDelegate {
    var window: UIWindow?
    var tabController: UITabBarController?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
    ) -> Bool {
        tabController = UITabBarController()
        tabController?.setViewControllers(visibleTabs(store.state.tabs), animated: false)
        tabController?.selectedIndex = 2

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabController
        window?.makeKeyAndVisible()
        return true
    }
}

func visibleTabs(_ tabs: [StoryType: StoryList]) -> [UIViewController] {
    return tabs.enumerated().map { (index, tab) in
        let storyController = StoryListViewController(tab.key)
        let navigationController = UINavigationController(rootViewController: storyController)
        navigationController.tabBarItem = UITabBarItem(title: tab.key.description, image: .none, tag: index)
        return navigationController
    }
}
