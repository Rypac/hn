import AsyncDisplayKit
import UIKit

final class LoadingCellNode: ASCellNode {
    let spinner = SpinnerNode()

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 8,
            justifyContent: .center,
            alignItems: .center,
            children: [spinner])
    }
}

final class SpinnerNode: ASDisplayNode {
    override init() {
        super.init()
        setViewBlock {
            UIActivityIndicatorView(activityIndicatorStyle: .gray)
        }
    }

    override func didLoad() {
        super.didLoad()
        if let activityIndicator = view as? UIActivityIndicatorView {
            activityIndicator.startAnimating()
        }
    }
}
