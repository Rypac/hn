import PromiseKit

func firstly<T>(_ synchronousAction: () -> T) -> Promise<T> {
    return Promise(value: synchronousAction())
}

extension Optional where Wrapped == Promise<Void> {
    func regardless(_ perform: @escaping () -> Void) {
        switch self {
        case .some(let promise):
            promise.always {
                perform()
            }
        case .none:
            perform()
        }
    }
}
