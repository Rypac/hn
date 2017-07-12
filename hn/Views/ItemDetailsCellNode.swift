import AsyncDisplayKit
import UIKit

final class ItemDetailCellNode: ASCellNode, BindableView {
    typealias ViewModel = Post

    let title = ASTextNode()
    let details = ASTextNode()

    func bind(viewModel post: Post) {
        guard let content = post.content.details else {
            return
        }

        title.attributedText = content.attributedTitle()
        details.attributedText = content.attributedDetails()
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

extension Post.Details {
    fileprivate func attributedTitle() -> NSAttributedString {
        let text = NSAttributedString(
            string: title,
            attributes: [NSFontAttributeName: Font.avenirNext.headline])

        guard let url = url, let link = URL(string: url)?.prettyHost else {
            return text
        }

        return text + NSAttributedString(
            string: "  (\(link))",
            attributes: [
                NSFontAttributeName: Font.avenirNext.caption1,
                NSForegroundColorAttributeName: UIColor.darkGray
            ])
    }

    fileprivate func attributedDetails() -> NSAttributedString {
        let score = "\(self.score) points"
        let author = "by \(self.author)"
        let time = Date(timeIntervalSince1970: TimeInterval(self.time)).relative(to: Date())
        return NSAttributedString(
            string: [score, author, time].joined(separator: " "),
            attributes: [
                NSFontAttributeName: Font.avenirNext.footnote,
                NSForegroundColorAttributeName: UIColor.darkGray])
    }
}
