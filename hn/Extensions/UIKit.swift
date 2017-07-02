import UIKit

extension UIEdgeInsets {
    init(all margin: CGFloat) {
        self.init(top: margin, left: margin, bottom: margin, right: margin)
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
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
