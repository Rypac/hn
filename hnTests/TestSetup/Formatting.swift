@testable import hn

extension Formatting: Equatable {
    public static func == (_ lhs: Formatting, _ rhs: Formatting) -> Bool {
        switch (lhs, rhs) {
        case let (.url(lhs), .url(rhs)):
            return lhs == rhs
        case (.bold, .bold),
             (.italic, .italic),
             (.underline, .underline),
             (.code, .code),
             (.preformatted, .preformatted),
             (.linebreak, .linebreak),
             (.paragraph, .paragraph):
            return true
        default:
            return false
        }
    }
}
