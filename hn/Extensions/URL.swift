import Foundation

extension URL {
    var prettyHost: String? {
        guard let host = host else {
            return .none
        }

        let www = "www."
        return host.hasPrefix(www) ? host.substring(from: www.endIndex) : host
    }
}
