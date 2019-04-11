import UIKit

final class NameCell: UICollectionViewCell {
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.adjustsFontForContentSizeCategory = true
    label.font = .preferredFont(forTextStyle: .body)
    return label
  }()

  override func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }

  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    commonInit()
  }

  private func commonInit() {
    contentView.backgroundColor = .clear
    contentView.addSubview(titleLabel)

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      titleLabel.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
    ])
  }

  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    titleLabel.preferredMaxLayoutWidth = layoutAttributes.size.width - contentView.layoutMargins.left - contentView.layoutMargins.right
    layoutAttributes.bounds.size.height = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    return layoutAttributes
  }
}

extension NameCell: CellReusable {
  static var reuseIdentifier: String {
    return "NameCell"
  }
}

extension NameCell {
  func bind(story: ViewModel.Story) {
    titleLabel.text = story.title
  }
}
