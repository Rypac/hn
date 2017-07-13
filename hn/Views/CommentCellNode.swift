import AsyncDisplayKit
import UIKit

final class CommentCellNode: ASCellNode, BindableView {
    typealias ViewModel = CommentViewModel

    let text = ASTextNode()
    let details = ASTextNode()
    private var model: CommentViewModel {
        didSet {
            if model.comment.actions.collapsed != oldValue.comment.actions.collapsed {
                setNeedsLayout()
            }
        }
    }

    init(viewModel: CommentViewModel) {
        model = viewModel
        super.init()
        automaticallyManagesSubnodes = true
        bind(viewModel: viewModel)
    }

    override func didLoad() {
        super.didLoad()
        layer.as_allowsHighlightDrawing = true
    }

    func bind(viewModel: ViewModel) {
        let (text, details) = viewModel.comment.cellText()

        self.text.attributedText = text?.attributedText(withFont: Font.avenirNext.body)
        self.text.linkAttributeNames = [kFormattingAttributes]
        self.details.attributedText = NSAttributedString(
            string: details,
            attributes: [
                NSFontAttributeName: Font.avenirNext.footnote,
                NSForegroundColorAttributeName: UIColor.darkGray
            ])

        model = viewModel
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let depth = min(CGFloat(model.comment.depth), 12)
        let children = model.comment.actions.collapsed ? [details] : [details, text]
        return ASInsetLayoutSpec(
            insets: UIEdgeInsets(
                top: UIEdgeInsets.Default.vertical,
                left: UIEdgeInsets.Default.horizontal + 10 * depth,
                bottom: UIEdgeInsets.Default.vertical,
                right: UIEdgeInsets.Default.horizontal),
            child: ASStackLayoutSpec(
                direction: .vertical,
                spacing: 4,
                flex: (shrink: 1.0, grow: 1.0),
                children: children))
    }
}

extension Comment {
     fileprivate func cellText() -> (FormattedString?, String) {
        switch content {
        case .details(let content):
            let time = Date(timeIntervalSince1970: TimeInterval(content.time)).relative(to: Date())
            return (content.text, "\(content.author) \(time)")
        case .dead:
            return (.none, "dead")
        case .deleted:
            return (.none, "deleted")
        }
    }
}
