import Alamofire

protocol JsonDecodable {
    init?(json: [String: Any])
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

func fetch<T: JsonDecodable>(_ endpoint: URLConvertible, onCompletion: @escaping (Result<T>) -> Void) {
    Alamofire.request(endpoint).validate().responseJSON { response in
        if let json = response.value as? [String: Any], let decoded = T(json: json) {
            onCompletion(.success(decoded))
        } else {
            onCompletion(.failure("Error decoding JSON object as \(T.self)"))
        }
    }
}

func fetch<T: JsonDecodable>(_ endpoint: URLConvertible, onCompletion: @escaping (Result<[T]>) -> Void) {
    Alamofire.request(endpoint).validate().responseJSON { response in
        if let json = response.value as? [[String: Any]] {
            let decoded = json.flatMap { T(json: $0) }
            if decoded.count == json.count {
                onCompletion(.success(decoded))
                return
            }
        }
        onCompletion(.failure("Error decoding JSON object as [\(T.self)]"))
    }
}

func fetch<T>(_ endpoint: URLConvertible, onCompletion: @escaping (T) -> Void) {
    Alamofire.request(endpoint).validate().responseJSON { response in
        (response.result.value as? T).map(onCompletion)
    }
}

func fetch<T>(_ endpoint: URLConvertible, onCompletion: @escaping ([T]) -> Void) {
    Alamofire.request(endpoint).validate().responseJSON { response in
        (response.result.value as? [T]).map(onCompletion)
    }
}
