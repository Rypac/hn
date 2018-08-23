import IGListKit

final class PostViewModel: ListDiffable {
  let post: Post

  init(_ post: Post) {
    self.post = post
  }

  func diffIdentifier() -> NSObjectProtocol {
    return post.id as NSNumber
  }

  func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    guard let object = object as? PostViewModel else {
      return false
    }
    return post.actions == object.post.actions &&
      post.content == object.post.content &&
      post.descendants == object.post.descendants
  }
}
