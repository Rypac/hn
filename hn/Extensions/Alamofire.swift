import Alamofire
import PromiseKit

protocol JsonDecodable {
    init?(json: [String: Any])
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

private func request(_ endpoint: URLConvertible) -> Promise<DataResponse<Any>> {
    return PromiseKit.wrap {
        Alamofire.request(endpoint).validate().responseJSON(completionHandler: $0)
    }
}

func request<T: JsonDecodable>(_ endpoint: URLConvertible) -> Promise<T> {
    return request(endpoint).then { response in
        guard let json = response.value as? [String: Any], let decoded = T(json: json) else {
            throw "Error decoding JSON object as \(T.self)"
        }

        return Promise(value: decoded)
    }
}

func request<T>(_ endpoint: URLConvertible) -> Promise<T> {
    return request(endpoint).then { response in
        guard let result = response.result.value as? T else {
            throw "Error decoding value as \(T.self)"
        }

        return Promise(value: result)
    }
}
