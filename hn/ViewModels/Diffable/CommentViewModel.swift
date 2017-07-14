import IGListKit

final class CommentViewModel: ListDiffable {
    let comment: Comment

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
