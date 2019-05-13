import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  private lazy var services: Services = {
    let apiClient = APIClient()
    return Services(
      firebase: FirebaseService(apiClient: apiClient),
      algolia: AlgoliaService(apiClient: apiClient)
    )
  }()

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let navigationController = window?.rootViewController as! UINavigationController
    let viewController = navigationController.visibleViewController as! StoriesViewController
    viewController.viewModel = StoriesViewModel(services: services)

    return true
  }
}
