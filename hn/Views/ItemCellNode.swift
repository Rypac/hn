import AsyncDisplayKit
import UIKit

final class PostCellNode: ASCellNode, BindableView {
  typealias ViewModel = Post

  let text = ASTextNode()
  let details = ASTextNode()
  let comments = ASTextNode()

  private var viewModel: Post

  init(viewModel: Post) {
    self.viewModel = viewModel
    super.init()
    automaticallyManagesSubnodes = true
    bind(viewModel: viewModel)
  }

  func bind(viewModel post: Post) {
    guard let content = post.content.details else {
      return
    }

    text.attributedText = content.attributedTitle()
    details.attributedText = content.attributedDetails()
    comments.attributedText = NSAttributedString(
      string: "\(post.descendants)",
      attributes: [NSFontAttributeName: Font.avenirNext.title3]
    )
  }

  override func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
    let postContent = ASStackLayoutSpec(
      direction: .vertical,
      spacing: 4,
      flex: (shrink: 1.0, grow: 1.0),
      children: [text, details]
    )

    return ASInsetLayoutSpec(
      insets: UIEdgeInsets.Default.tableViewCell,
      child: ASStackLayoutSpec(
        direction: .horizontal,
        spacing: 20,
        justifyContent: .start,
        alignItems: .center,
        children: viewModel.type == .job ? [postContent] : [postContent, comments]
      )
    )
  }
}

extension Post.Details {
  fileprivate func attributedTitle() -> NSAttributedString {
    let text = NSAttributedString(
      string: title,
      attributes: [NSFontAttributeName: Font.avenirNext.body]
    )

    guard let url = url, let link = URL(string: url)?.prettyHost else {
      return text
    }

    return text + NSAttributedString(
      string: "  (\(link))",
      attributes: [
        NSFontAttributeName: Font.avenirNext.caption1,
        NSForegroundColorAttributeName: UIColor.darkGray,
      ]
    )
  }

  fileprivate func attributedDetails() -> NSAttributedString {
    let score = "\(self.score) points"
    let author = "by \(self.author)"
    let time = Date(timeIntervalSince1970: TimeInterval(self.time)).relative(to: Date())
    return NSAttributedString(
      string: [score, author, time].joined(separator: " "),
      attributes: [
        NSFontAttributeName: Font.avenirNext.footnote,
        NSForegroundColorAttributeName: UIColor.darkGray,
      ]
    )
  }
}
