import AsyncDisplayKit
import UIKit

final class ItemCellNode: ASCellNode {
    let text = ASTextNode()
    let details = ASTextNode()
    let comments = ASTextNode()

    init(_ post: Post) {
        super.init()
        automaticallyManagesSubnodes = true

        guard let content = post.content.details else {
            return
        }

        let author = "by \(content.author)"
        let score = "\(content.score) points"
        let time = Date(timeIntervalSince1970: TimeInterval(content.time)).relative(to: Date())

        text.attributedText = NSAttributedString(
            string: content.title,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
        details.attributedText = NSAttributedString(
            string: [author, score, time].joined(separator: " "),
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
        comments.attributedText = NSAttributedString(
            string: "\(post.descendants)",
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .body)])
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets.Default.tableViewCell,
            child: ASStackLayoutSpec(
                direction: .horizontal,
                spacing: 20,
                justifyContent: .start,
                alignItems: .center,
                children: [
                    ASStackLayoutSpec(
                        direction: .vertical,
                        spacing: 4,
                        flex: (shrink: 1.0, grow: 1.0),
                        children: [text, details]),
                    comments
                ]))
    }
}
