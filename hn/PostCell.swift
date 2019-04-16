import UIKit

final class PostCell: UITableViewCell {
  private lazy var verticalStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()

  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    label.numberOfLines = 0
    return label
  }()

  private lazy var detailsTextLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.numberOfLines = 0
    return label
  }()

  private lazy var urlLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontForContentSizeCategory = true
    label.font = UIFont.preferredFont(forTextStyle: .subheadline)
    label.numberOfLines = 1
    label.textColor = UIColor.Apple.blue
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
    verticalStackView.addArrangedSubview(detailsTextLabel)
    verticalStackView.addArrangedSubview(urlLabel)
    verticalStackView.addArrangedSubview(horizontalStackView)
    horizontalStackView.addArrangedSubview(authorLabel)
    horizontalStackView.addArrangedSubview(scoreLabel)
  }
}

extension PostCell: ReusableCell {
  static var reuseIdentifier: String {
    return "PostCell"
  }
}

extension PostCell {
  func bind(post: CommentsViewModel.Post) {
    titleLabel.text = post.title
    authorLabel.text = post.user
    scoreLabel.text = "\(post.score) points"
    urlLabel.text = post.url
    urlLabel.isHidden = post.url.isEmpty
    detailsTextLabel.text = post.text
    detailsTextLabel.isHidden = post.text.isEmpty
  }
}
