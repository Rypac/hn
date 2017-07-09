import AsyncDisplayKit
import UIKit

final class ItemCellNode: ASCellNode, BindableView {
    typealias ViewModel = Post

    let text = ASTextNode()
    let details = ASTextNode()
    let comments = ASTextNode()

    func bind(viewModel post: Post) {
        guard let content = post.content.details else {
            return
        }

        let author = "by \(content.author)"
        let score = "\(content.score) points"
        let time = Date(timeIntervalSince1970: TimeInterval(content.time)).relative(to: Date())

        text.attributedText = NSAttributedString(
            string: content.title,
            attributes: [NSFontAttributeName: Font.avenirNext.body])
        details.attributedText = NSAttributedString(
            string: [score, author, time].joined(separator: " "),
            attributes: [NSFontAttributeName: Font.avenirNext.footnote])
        comments.attributedText = NSAttributedString(
            string: "\(post.descendants)",
            attributes: [NSFontAttributeName: Font.avenirNext.title3])
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
