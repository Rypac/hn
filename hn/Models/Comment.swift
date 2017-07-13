import Foundation

struct Comment {
    struct Details {
        let text: FormattedString
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
    let responses: [Id]
    var depth: Int
    var actions: Actions
}

extension Comment {
    var isOrphaned: Bool {
        switch content {
        case .dead, .deleted: return responses.isEmpty
        default: return false
        }
    }
}

// MARK: - ItemInitialisable

extension Comment: ItemInitialisable {
    init?(fromItem item: Item) {
        guard let details = Content<Details>(fromItem: item) else {
            return nil
        }
        id = item.id
        content = details
        responses = item.kids.map { $0.id }
        actions = Actions(upvoted: false, saved: false, collapsed: false)
        depth = 0
    }

    init?(fromItem item: Item, depth: Int) {
        self.init(fromItem: item)
        self.depth = depth
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
        self.text = text.strippingHtmlElements()
        self.author = author
        self.time = time
        self.parent = item.parent ?? 0
    }
}

// MARK: - Equatable

extension Comment: Equatable {
    static func == (_ lhs: Comment, _ rhs: Comment) -> Bool {
        return lhs.id == rhs.id &&
            lhs.actions == rhs.actions &&
            lhs.content == rhs.content &&
            lhs.responses == rhs.responses
    }
}

extension Comment.Details: Equatable {
    static func == (_ lhs: Comment.Details, _ rhs: Comment.Details) -> Bool {
        return lhs.text == rhs.text
    }
}

extension Comment.Actions: Equatable {
    static func == (_ lhs: Comment.Actions, _ rhs: Comment.Actions) -> Bool {
        return lhs.collapsed == rhs.collapsed
    }
}
