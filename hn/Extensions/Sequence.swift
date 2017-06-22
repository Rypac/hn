import Foundation

extension Sequence {
    func forAllAsync<U>(_ performAsync: (Self.Iterator.Element, @escaping ([U]) -> Void) -> Void, after: @escaping ([U]) -> Void) {
        var values = [U]()
        let requestGroup = DispatchGroup()
        self.forEach { value in
            requestGroup.enter()
            performAsync(value) { asyncValue in
                values += asyncValue
                requestGroup.leave()
            }
        }
        requestGroup.notify(queue: .main) {
            after(values)
        }
    }
}
