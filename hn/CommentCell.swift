import UIKit

final class CommentCell: UICollectionViewCell {
  private lazy var verticalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 4
    return stackView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.numberOfLines = 0
    return label
  }()

  private lazy var authorLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.textColor = .darkGray
    label.numberOfLines = 1
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()

  private lazy var leadingConstraint: NSLayoutConstraint = {
    verticalStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
  }()

  override func awakeFromNib() {
    super.awakeFromNib()

    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.addSubview(verticalStackView)

    verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      verticalStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      verticalStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      verticalStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
      leadingConstraint
    ])

    verticalStackView.addArrangedSubview(authorLabel)
    verticalStackView.addArrangedSubview(titleLabel)
  }

  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    layoutAttributes.bounds.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
    return layoutAttributes
  }
}

extension CommentCell: ReusableCell {
  static var reuseIdentifier: String {
    return "CommentCell"
  }
}

extension CommentCell {
  func bind(comment: CommentsViewModel.Comment) {
    titleLabel.text = comment.text
    authorLabel.text = comment.user
    leadingConstraint.constant = 8 * CGFloat(comment.depth)
  }
}
