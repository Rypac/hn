import UIKit

final class StoryCell: UICollectionViewCell {
  private lazy var verticalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.numberOfLines = 0
    return label
  }()

  private lazy var horizontalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.spacing = 8
    return stackView
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

  private lazy var scoreLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.textColor = .orange
    label.numberOfLines = 1
    return label
  }()

  override func awakeFromNib() {
    super.awakeFromNib()

    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    contentView.addSubview(verticalStackView)

    verticalStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      verticalStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      verticalStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      verticalStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      verticalStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
    ])

    verticalStackView.addArrangedSubview(titleLabel)
    verticalStackView.addArrangedSubview(horizontalStackView)
    horizontalStackView.addArrangedSubview(authorLabel)
    horizontalStackView.addArrangedSubview(scoreLabel)
  }

  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    layoutAttributes.bounds.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
    return layoutAttributes
  }
}

extension StoryCell: ReusableCell {
  static var reuseIdentifier: String {
    return "StoryCell"
  }
}

extension StoryCell {
  func bind(story: StoriesViewModel.Story) {
    titleLabel.text = story.title
    authorLabel.text = story.user
    scoreLabel.text = "\(story.score) points"
  }
}
