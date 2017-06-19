import UIKit
import AlamofireNetworkActivityIndicator
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
        selectedTab: .none,
        selectedStory: .none))

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

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: tabController)
        window?.makeKeyAndVisible()
        return true
    }
}

func visibleTabs(_ tabs: [StoryType: StoryList]) -> [UIViewController] {
    return tabs.enumerated().map { (index, tab) in
        let storyController = StoryListViewController(tab.key)
        storyController.tabBarItem = UITabBarItem(title: tab.key.description, image: .none, tag: index)
        return storyController
    }
}
