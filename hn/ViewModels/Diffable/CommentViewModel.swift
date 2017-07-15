import IGListKit

final class CommentViewModel: ListDiffable {
    let comment: Comment

    lazy var title: NSAttributedString? =
        self.comment.content.details?.text.attributedText(withFont: Font.avenirNext.body)

    lazy var details: NSAttributedString = NSAttributedString(
        string: self.comment.cellDetails,
        attributes: [
            NSFontAttributeName: Font.avenirNext.footnote,
            NSForegroundColorAttributeName: UIColor.darkGray
        ])

    init(_ comment: Comment) {
        self.comment = comment
    }

    func diffIdentifier() -> NSObjectProtocol {
        return comment.id as NSNumber
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? CommentViewModel else {
            return false
        }
        return comment.depth == object.comment.depth &&
            comment.actions == object.comment.actions &&
            comment.content == object.comment.content
    }
}

extension Comment {
    fileprivate var cellDetails: String {
        switch content {
        case .details(let content):
            let time = Date(timeIntervalSince1970: TimeInterval(content.time)).relative(to: Date())
            return "\(content.author) \(time)"
        case .dead:
            return "dead"
        case .deleted:
            return "deleted"
        }
    }
}
