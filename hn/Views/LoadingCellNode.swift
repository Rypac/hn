import AsyncDisplayKit
import UIKit

final class LoadingCellNode: ASCellNode {
    let spinner = SpinnerNode()
    let text = ASTextNode()

    override init() {
        super.init()
        automaticallyManagesSubnodes = true
        text.attributedText = NSAttributedString(
            string: "Loading...",
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(
            direction: .horizontal,
            spacing: 8,
            justifyContent: .center,
            alignItems: .center,
            children: [text, spinner])
    }
}

final class SpinnerNode: ASDisplayNode {
    override init() {
        super.init()
        setViewBlock {
            UIActivityIndicatorView(activityIndicatorStyle: .gray)
        }
        style.preferredSize = CGSize(width: 20.0, height: 20.0)
    }

    override func didLoad() {
        super.didLoad()
        if let activityIndicator = view as? UIActivityIndicatorView {
            activityIndicator.startAnimating()
        }
    }
}
