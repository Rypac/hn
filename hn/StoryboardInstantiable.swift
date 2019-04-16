import UIKit

protocol StoryboardInstantiable: UIViewController {
  static var storyboardIdentifier: String { get }
}

extension UIStoryboard {
  func instantiateViewController<T>(ofType: T.Type) -> T where T: StoryboardInstantiable {
    return instantiateViewController(withIdentifier: T.storyboardIdentifier) as! T
  }

  func instantiateViewController<T>(ofType: T.Type, viewModel: T.ViewModel) -> T where T: ViewModelAssignable & StoryboardInstantiable {
    let viewController = instantiateViewController(ofType: T.self)
    viewController.viewModel = viewModel
    return viewController
  }
}

extension ViewModelAssignable where Self: StoryboardInstantiable {
  static func make(viewModel: ViewModel) -> Self {
    return UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(ofType: Self.self, viewModel: viewModel)
  }
}
