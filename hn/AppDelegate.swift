import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let navigationController = window?.rootViewController as! UINavigationController
    let viewController = navigationController.visibleViewController as! StoriesViewController
    viewController.viewModel = StoriesViewModel(services: Services())

    return true
  }
}
