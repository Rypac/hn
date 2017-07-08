import AsyncDisplayKit
import UIKit

final class ItemDetailCellNode: ASCellNode {
    let title = ASTextNode()
    let details = ASTextNode()

    init(_ post: Post) {
        super.init()
        automaticallyManagesSubnodes = true

        guard let content = post.content.details else {
            return
        }

        let author = "by \(content.author)"
        let score = "\(content.score) points"
        let time = Date(timeIntervalSince1970: TimeInterval(content.time)).relative(to: Date())

        title.attributedText = NSAttributedString(
            string: content.title,
            attributes: [NSFontAttributeName: Font.avenirNext.headline])
        details.attributedText = NSAttributedString(
            string: [author, score, time].joined(separator: " "),
            attributes: [NSFontAttributeName: Font.avenirNext.footnote])
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets.Default.tableViewCell,
            child: ASStackLayoutSpec(
                direction: .vertical,
                spacing: 4,
                flex: (shrink: 1.0, grow: 1.0),
                children: [title, details]))
    }
}
