import UIKit
import AsyncDisplayKit

final class ItemDetailCellNode: ASCellNode {
    let title = ASTextNode()
    let details = ASTextNode()

    override init() {
        super.init()
        addSubnode(title)
        addSubnode(details)
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let cellStack = ASStackLayoutSpec.vertical()
        cellStack.spacing = 4
        cellStack.style.flexShrink = 1.0
        cellStack.style.flexGrow = 1.0
        cellStack.children = [title, details]

        return ASInsetLayoutSpec(insets: UIEdgeInsets(horizontal: 8, vertical: 4), child: cellStack)
    }
}

extension ItemDetailCellNode {
    convenience init(_ item: Item) {
        self.init()
        guard let text = item.title else {
            return
        }

        let author = item.by.map { "by \($0)" }
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
}
