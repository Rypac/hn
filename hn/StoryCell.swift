import UIKit

final class StoryCell: UICollectionViewCell {
  @IBOutlet private var stackView: UIStackView!
  @IBOutlet private var titleLabel: UILabel!
  @IBOutlet private var scoreLabel: UILabel!
  @IBOutlet private var authorLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }

  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    commonInit()
  }

  private func commonInit() {
  }

  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    layoutAttributes.bounds.size = systemLayoutSizeFitting(UIView.layoutFittingCompressedSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
    return layoutAttributes
  }
}

extension StoryCell: CellReusable {
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
