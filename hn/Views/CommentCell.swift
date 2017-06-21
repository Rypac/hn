import UIKit
import AsyncDisplayKit

final class CommentCellNode: ASCellNode {
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
            children: [details, text])
    }

    func update(comment: String, author: String, timestamp: Int) {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let timeSincePosting = date.relative(to: Date())
        text.attributedText = NSAttributedString(
            string: comment,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        details.attributedText = NSAttributedString(
            string: "\(author) \(timeSincePosting)",
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
    }
}
