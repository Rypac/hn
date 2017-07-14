@testable import hn

extension Item {
    init(withId id: Int, kids: [Reference<Item>]) {
        self.init(
            id: id,
            type: .story,
            title: .none,
            text: .none,
            score: .none,
            author: .none,
            time: .none,
            url: .none,
            parent: .none,
            descendants: .none,
            kids: kids,
            parts: .none,
            dead: false,
            deleted: false)
    }
}

extension Reference where T == Item {
    var id: Int {
        switch self {
        case let .id(id):
            return id
        case let .value(item):
            return item.id
        }
    }
}

extension Item {
    static func fake(_ type: Item.PostType, id: Id, kids: [Item] = []) -> Item {
        return Item(
            id: id,
            type: type,
            title: "Clickbait title",
            text: "<p>A <b>really</b> long and <i>interesting</i> comment</p>",
            score: 27,
            author: "hunter2",
            time: 1234,
            url: "https://www.google.com",
            parent: .none,
            descendants: kids.count,
            kids: kids.map(Reference.value),
            parts: .none,
            dead: false,
            deleted: false)
    }
}
