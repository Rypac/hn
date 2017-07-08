import UIKit

extension IndexPath {
    func `as`<T: RawRepresentable>(_ type: T.Type) -> T? where T.RawValue == Int {
        return T(rawValue: section)
    }
}

extension UIEdgeInsets {
    init(all margin: CGFloat) {
        self.init(top: margin, left: margin, bottom: margin, right: margin)
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    struct Default {
        static let vertical: CGFloat = 8
        static let horizontal: CGFloat = 15

        static let tableViewCell = UIEdgeInsets(horizontal: horizontal, vertical: vertical)
    }
}

extension UIRefreshControl {
    func manuallyBeginRefreshing(inView view: UIScrollView) {
        beginRefreshing()

        weak var weakView = view
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now(), execute: { [weak self] in
            guard let strongSelf = self, let view = weakView else {
                return
            }
            view.setContentOffset(
                CGPoint(x: 0, y: view.contentOffset.y - strongSelf.frame.size.height),
                animated: true)
        })
    }
}
