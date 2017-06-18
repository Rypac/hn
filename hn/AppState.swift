import Foundation
import ReSwift

struct AppState: StateType {
    var ids = [Int]()
    var stories = [Story]()
    var fetchingMore = false
}
