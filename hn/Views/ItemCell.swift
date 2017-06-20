import UIKit
import AsyncDisplayKit

final class ItemCellNode: ASCellNode {
    let text = ASTextNode()
    let details = ASTextNode()

    override init() {
        super.init()
        addSubnode(text)
        addSubnode(details)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASStackLayoutSpec(
            direction: .vertical,
            spacing: 6,
            justifyContent: .center,
            alignItems: .start,
            children: [text, details])
    }

    func update(title: String, author: String, score: Int, time: Int) {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let timeSincePosting = date.relative(to: Date())
        text.attributedText = NSAttributedString(
            string: title,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        details.attributedText = NSAttributedString(
            string: "\(score) points by \(author) \(timeSincePosting)",
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
    }
}
