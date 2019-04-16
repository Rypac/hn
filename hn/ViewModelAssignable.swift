import UIKit

protocol ViewModelAssignable: UIViewController {
  associatedtype ViewModel

  var viewModel: ViewModel! { get set }
}
