import AsyncDisplayKit

protocol BindableView {
    associatedtype ViewModel

    init(viewModel: ViewModel)
    func bind(viewModel: ViewModel)
}

extension BindableView where Self: ASDisplayNode {
    init(viewModel: ViewModel) {
        self.init()
        automaticallyManagesSubnodes = true
        bind(viewModel: viewModel)
    }
}
