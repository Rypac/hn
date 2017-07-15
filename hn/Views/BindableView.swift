import UIKit

protocol BindableView {
    associatedtype ViewModel

    init(viewModel: ViewModel)
    func bind(viewModel: ViewModel)
}

extension BindableView where Self: UIView {
    init(viewModel: ViewModel) {
        self.init()
        bind(viewModel: viewModel)
    }
}
