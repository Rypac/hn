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

        text.attributedText = content.attributedTitle()
        details.attributedText = content.attributedDetails()
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

extension Post.Details {
    fileprivate func attributedTitle() -> NSAttributedString {
        let text = NSAttributedString(
            string: title,
            attributes: [NSFontAttributeName: Font.avenirNext.body])

        guard let url = url, let link = URL(string: url)?.prettyHost else {
            return text
        }

        return text + NSAttributedString(
            string: "  (\(link))",
            attributes: [NSFontAttributeName: Font.avenirNext.caption1])
    }

    fileprivate func attributedDetails() -> NSAttributedString {
        let score = "\(self.score) points"
        let author = "by \(self.author)"
        let time = Date(timeIntervalSince1970: TimeInterval(self.time)).relative(to: Date())
        return NSAttributedString(
            string: [score, author, time].joined(separator: " "),
            attributes: [NSFontAttributeName: Font.avenirNext.footnote])
    }
}
