import Foundation

enum HTTPMethod: String {
  case get = "GET"
  case put = "PUT"
  case post = "POST"
  case delete = "DELETE"
  case head = "HEAD"
  case options = "OPTIONS"
  case trace = "TRACE"
  case connect = "CONNECT"
}

struct APIResponse<Body> {
  let statusCode: Int
  let body: Body
}

enum APIError: Error {
  case requestFailed
  case unknown(Error)
}

class APIClient {
  typealias Completion = (Result<APIResponse<Data?>, APIError>) -> Void

  private let session: URLSession

  init(configuration: URLSessionConfiguration = .default) {
    self.session = URLSession(configuration: .default)
  }

  func perform(_ request: URLRequest, _ completion: @escaping Completion) -> URLSessionTask {
    let task = session.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(.unknown(error)))
        return
      }
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(.failure(.requestFailed))
        return
      }
      completion(.success(APIResponse(statusCode: httpResponse.statusCode, body: data)))
    }
    task.resume()
    return task
  }
}

extension APIClient {
  @discardableResult
  func get(_ url: URL, _ completion: @escaping Completion) -> URLSessionTask {
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = HTTPMethod.get.rawValue
    return perform(urlRequest, completion)
  }
}
