import Foundation

extension URL {
  private static let www = "www."

  var prettyHost: String? {
    guard let host = host else {
      return .none
    }

    return host.hasPrefix(URL.www) ? String(host[URL.www.endIndex...]) : host
  }
}
