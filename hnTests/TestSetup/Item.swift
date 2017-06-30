@testable import hn

extension Item {
    init(withId id: Int, kids: [Reference<Item>]) {
        self.init(
            id: id,
            title: .none,
            text: .none,
            score: .none,
            author: .none,
            time: .none,
            type: .none,
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
