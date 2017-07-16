import UIKit

final class CommentCell: UITableViewCell, BindableView {
    typealias ViewModel = CommentViewModel

    let commentText = UITextView()
    let commentDetails = UITextView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        commentText.translatesAutoresizingMaskIntoConstraints = true
        commentText.adjustsFontForContentSizeCategory = true
        commentText.contentInset = UIEdgeInsets(
            horizontal: -commentText.textContainer.lineFragmentPadding,
            vertical: 0)
        commentText.textContainerInset = .zero
        commentText.isEditable = false
        commentText.isScrollEnabled = false
        commentText.isSelectable = false

        commentDetails.translatesAutoresizingMaskIntoConstraints = true
        commentDetails.adjustsFontForContentSizeCategory = true
        commentDetails.contentInset = UIEdgeInsets(
            horizontal: -commentDetails.textContainer.lineFragmentPadding,
            vertical: 0)
        commentDetails.textContainerInset = .zero
        commentDetails.isEditable = false
        commentDetails.isScrollEnabled = false
        commentDetails.isSelectable = false

        contentView.addSubview(commentText)
        contentView.addSubview(commentDetails)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = contentView.bounds.width
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let textHeight = ceil(commentText.attributedText.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            context: nil).size.height)
        let detailsHeight = ceil(commentDetails.attributedText.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            context: nil).size.height)

        commentDetails.frame = CGRect(x: 0, y: 0, width: width, height: detailsHeight)
        commentText.frame = CGRect(x: 0, y: detailsHeight + 8, width: width, height: textHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    func bind(viewModel: ViewModel) {
        commentText.attributedText = viewModel.title
        commentDetails.attributedText = viewModel.details
    }
}
