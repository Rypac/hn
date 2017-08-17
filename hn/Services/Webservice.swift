import PromiseKit
import UIKit

typealias JSONDictionary = [String: Any]

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

struct Resource<T> {
    let url: URL
    let parse: (Data) -> T?
}

extension Resource {
    init(url: URL, parseJSON: @escaping (Any) -> T? = { $0 as? T }) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            return json.flatMap(parseJSON)
        }
    }

    init(url: URL, parseJSON: @escaping (JSONDictionary) -> T?) {
        self.url = url
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            return (json as? JSONDictionary).flatMap(parseJSON)
        }
    }
}

final class Webservice {
    func load<T>(resource: Resource<T>) -> Promise<T> {
        return wrap { (completion: (@escaping (T?, Error?) -> Void)) in
            URLSession.shared.dataTask(with: resource.url) { data, _, _ in
                guard let json = data.flatMap(resource.parse) else {
                    completion(.none, "Error parsing JSON")
                    return
                }
                completion(json, .none)
            }.resume()
        }
    }
}
