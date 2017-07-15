import UIKit

final class CommentCell: UITableViewCell, BindableView {
    typealias ViewModel = CommentViewModel

    let commentTextLabel = UILabel()
    let commentDetailsLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commentTextLabel.numberOfLines = 0
        commentTextLabel.adjustsFontForContentSizeCategory = true
        commentDetailsLabel.numberOfLines = 1
        commentDetailsLabel.adjustsFontForContentSizeCategory = true

        contentView.addSubview(commentTextLabel)
        contentView.addSubview(commentDetailsLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        commentDetailsLabel.translatesAutoresizingMaskIntoConstraints = false
        commentTextLabel.translatesAutoresizingMaskIntoConstraints = false

        commentDetailsLabel.leadingAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        commentDetailsLabel.trailingAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        commentDetailsLabel.topAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true

        commentTextLabel.leadingAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        commentTextLabel.trailingAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        commentTextLabel.topAnchor.constraint(
            equalTo: commentDetailsLabel.bottomAnchor,
            constant: 6).isActive = true
        commentTextLabel.bottomAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    func bind(viewModel: ViewModel) {
        commentTextLabel.attributedText = viewModel.title
        commentDetailsLabel.attributedText = viewModel.details
    }
}
