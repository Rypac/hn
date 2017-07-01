import AsyncDisplayKit
import UIKit

final class ItemDetailCellNode: ASCellNode {
    let title = ASTextNode()
    let details = ASTextNode()

    init(_ item: Item) {
        super.init()
        automaticallyManagesSubnodes = true
        guard let text = item.title else {
            return
        }

        let author = item.author.map { "by \($0)" }
        let score = item.score.map { "\($0) points" }
        let time = item.time.map { Date(timeIntervalSince1970: TimeInterval($0)).relative(to: Date()) }
        let info = [score, author, time].flatMap { $0 }.joined(separator: " ")

        title.attributedText = NSAttributedString(
            string: text,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline)])
        details.attributedText = NSAttributedString(
            string: info,
            attributes: [NSFontAttributeName: UIFont.preferredFont(forTextStyle: .footnote)])
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(all: 8),
            child: ASStackLayoutSpec(
                direction: .vertical,
                spacing: 4,
                flex: (shrink: 1.0, grow: 1.0),
                children: [title, details]))
    }
}
