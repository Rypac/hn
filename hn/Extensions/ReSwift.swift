import PromiseKit
import ReSwift

extension Promise: Action {}

typealias AsyncActionCreator<State, T> = (_ state: State, _ store: Store<State>) -> Promise<T>? where State: StateType

extension Store {
    func dispatch(async actionCreatorProvider: @escaping AsyncActionCreator) -> Promise<State> {
        return wrap {
            dispatch(actionCreatorProvider, callback: $0)
        }
    }

    func dispatch<T>(async action: Promise<T>) -> Promise<T> {
        return action
    }

    func dispatch<T>(async action: hn.AsyncActionCreator<State, T>) -> Promise<T>? {
        return action(state, self).map(dispatch(async:))
    }
}
