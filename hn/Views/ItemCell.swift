import UIKit

final class ItemCell: UITableViewCell, BindableView {
    typealias ViewModel = Post

    let itemText = UILabel()
    let itemDetails = UILabel()
    let comments = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        itemText.numberOfLines = 0
        itemText.adjustsFontForContentSizeCategory = true
        itemDetails.numberOfLines = 1
        itemDetails.adjustsFontForContentSizeCategory = true
        comments.numberOfLines = 1
        comments.adjustsFontForContentSizeCategory = true
        comments.textAlignment = .right

        contentView.addSubview(itemText)
        contentView.addSubview(itemDetails)
        contentView.addSubview(comments)

        setupConstraints()
    }

    private func setupConstraints() {
        itemText.translatesAutoresizingMaskIntoConstraints = false
        itemDetails.translatesAutoresizingMaskIntoConstraints = false
        comments.translatesAutoresizingMaskIntoConstraints = false

        itemText.leadingAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        itemText.topAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true

        itemDetails.leadingAnchor.constraint(
            equalTo: itemText.leadingAnchor).isActive = true
        itemDetails.trailingAnchor.constraint(
            equalTo: itemText.trailingAnchor).isActive = true
        itemDetails.topAnchor.constraint(
            equalTo: itemText.bottomAnchor,
            constant: 6).isActive = true
        itemDetails.bottomAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true

        comments.leadingAnchor.constraint(
            equalTo: itemText.trailingAnchor,
            constant: 20).isActive = true
        comments.trailingAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        comments.topAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        comments.bottomAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(viewModel post: Post) {
        guard let content = post.content.details else {
            return
        }

        itemText.attributedText = content.attributedTitle()
        itemDetails.attributedText = content.attributedDetails()
        comments.attributedText = NSAttributedString(
            string: "\(post.descendants)",
            attributes: [NSFontAttributeName: Font.avenirNext.title3])
    }
}

extension Post.Details {
    fileprivate func attributedTitle() -> NSAttributedString {
        let text = NSAttributedString(
            string: title,
            attributes: [NSFontAttributeName: Font.avenirNext.body])

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
                NSForegroundColorAttributeName: UIColor.darkGray
            ])
    }
}
