import Foundation

struct Comment {
    struct Details {
        let text: String
        let author: String
        let time: UnixTimestamp
        let parent: Id
    }
    struct Actions {
        var upvoted: Bool
        var saved: Bool
        var collapsed: Bool
    }
    let id: Id
    let content: Content<Details>
    let responses: [Comment]
    var actions: Actions
}

extension Comment {
    var isOrphaned: Bool {
        switch content {
        case .dead, .deleted: return responses.isEmpty
        default: return false
        }
    }

    func flatten() -> [(Comment, Int)] {
        return flatten(depth: 0)
    }

    private func flatten(depth: Int) -> [(Comment, Int)] {
        return responses.reduce([(self, depth)]) { $0 + $1.flatten(depth: depth + 1) }
    }
}

extension Comment: ItemInitialisable {
    init?(fromItem item: Item) {
        guard let details = Content<Details>(fromItem: item) else {
            return nil
        }
        id = item.id
        content = details
        responses = item.kids.flatMap { $0.bindValue(Comment.init(fromItem:)) }
        actions = Actions(upvoted: false, saved: false, collapsed: false)
    }
}

extension Comment.Details: ItemInitialisable {
    init?(fromItem item: Item) {
        guard
            let text = item.text,
            let author = item.author,
            let time = item.time
        else {
            return nil
        }
        self.text = text
        self.author = author
        self.time = time
        self.parent = item.parent ?? 0
    }
}

extension Comment: Equatable {
    static func == (_ lhs: Comment, _ rhs: Comment) -> Bool {
        return lhs.id == rhs.id &&
            lhs.actions == rhs.actions &&
            lhs.responses == rhs.responses
    }
}

extension Comment.Actions: Equatable {
    static func == (_ lhs: Comment.Actions, _ rhs: Comment.Actions) -> Bool {
        return lhs.collapsed == rhs.collapsed
    }
}
