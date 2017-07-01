import Alamofire
import PromiseKit

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

private func request(_ endpoint: URLConvertible) -> Promise<DataResponse<Any>> {
    return wrap {
        Alamofire.request(endpoint).validate().responseJSON(completionHandler: $0)
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

func request<U, T>(_ endpoint: URLConvertible, withMapper mapper: @escaping (U) -> T?) -> Promise<T> {
    return request(endpoint).then { response in
        guard let json = response.value as? U, let decoded = mapper(json) else {
            throw "Error decoding value with mapping \(U.self) -> \(T.self)"
        }

        return Promise(value: decoded)
    }
}
