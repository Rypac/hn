import Foundation

struct Post {
    struct Details {
        let title: String
        let text: String?
        let author: String
        let time: UnixTimestamp
        let url: String?
        let score: Int
    }
    struct Actions {
        var upvoted: Bool
        var saved: Bool
        var hidden: Bool
    }
    let id: Id
    let content: Content<Details>
    let descendants: Int
    let comments: [Id]
    var actions: Actions
}

// MARK: - ItemInitialisable

extension Post: ItemInitialisable {
    init?(fromItem item: Item) {
        guard let details = Content<Details>(fromItem: item) else {
            return nil
        }
        id = item.id
        content = details
        descendants = item.descendants ?? 0
        comments = item.kids.map { $0.id }
        actions = Actions(upvoted: false, saved: false, hidden: false)
    }
}

extension Post.Details: ItemInitialisable {
    init?(fromItem item: Item) {
        guard
            let title = item.title,
            let author = item.author,
            let time = item.time,
            let score = item.score
        else {
            return nil
        }
        self.title = title
        self.author = author
        self.time = time
        self.score = score
        text = item.text
        url = item.url
    }
}

// MARK: - Equatable

extension Post: Equatable {
    static func == (_ lhs: Post, _ rhs: Post) -> Bool {
        return lhs.id == rhs.id &&
            lhs.content == rhs.content &&
            lhs.actions == rhs.actions &&
            lhs.comments == rhs.comments
    }
}

extension Post.Details: Equatable {
    static func == (_ lhs: Post.Details, _ rhs: Post.Details) -> Bool {
        return lhs.title == rhs.title &&
            lhs.text == rhs.text &&
            lhs.url == rhs.url
    }
}

extension Post.Actions: Equatable {
    static func == (_ lhs: Post.Actions, _ rhs: Post.Actions) -> Bool {
        return lhs.hidden == rhs.hidden
    }
}
