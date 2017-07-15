import UIKit

final class ItemDetailCell: UITableViewCell, BindableView {
    typealias ViewModel = Post

    let title = UILabel()
    let details = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white

        title.numberOfLines = 0
        title.adjustsFontForContentSizeCategory = true
        details.numberOfLines = 1
        details.adjustsFontForContentSizeCategory = true

        contentView.addSubview(title)
        contentView.addSubview(details)

        setupConstraints()
    }

    private func setupConstraints() {
        title.translatesAutoresizingMaskIntoConstraints = false
        details.translatesAutoresizingMaskIntoConstraints = false

        title.leadingAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        title.trailingAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        title.topAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true

        details.leadingAnchor.constraint(
            equalTo: title.leadingAnchor).isActive = true
        details.trailingAnchor.constraint(
            equalTo: title.trailingAnchor).isActive = true
        details.topAnchor.constraint(
            equalTo: title.bottomAnchor,
            constant: 6).isActive = true
        details.bottomAnchor.constraint(
            equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(viewModel post: Post) {
        guard let content = post.content.details else {
            return
        }

        title.attributedText = content.attributedTitle()
        details.attributedText = content.attributedDetails()
    }
}

extension Post.Details {
    fileprivate func attributedTitle() -> NSAttributedString {
        let text = NSAttributedString(
            string: title,
            attributes: [NSFontAttributeName: Font.avenirNext.headline])

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
                NSForegroundColorAttributeName: UIColor.darkGray])
    }
}
