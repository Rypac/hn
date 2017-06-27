@testable import hn

extension Item {
    init(withId id: Int, kids: [Int]?) {
        self.init(
            id: id,
            title: .none,
            text: .none,
            score: .none,
            by: .none,
            time: .none,
            type: .none,
            url: .none,
            descendants: .none,
            kids: kids,
            parts: .none,
            dead: false,
            deleted: false)
    }
}
