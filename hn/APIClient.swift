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

struct HTTPHeader {
  let field: String
  let value: String
}

struct APIResponse<Body> {
  let statusCode: Int
  let body: Body
}

enum APIError: Error {
  case invalidURL
  case requestFailed
}

class APIClient {
  typealias Completion = (Result<APIResponse<Data?>, APIError>) -> Void

  private let session: URLSession

  init(configuration: URLSessionConfiguration = .default) {
    self.session = URLSession(configuration: .default)
  }

  @discardableResult
  func get(_ url: URL, _ completion: @escaping Completion) -> URLSessionTask {
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = HTTPMethod.get.rawValue
    return perform(urlRequest, completion)
  }

  @discardableResult
  func perform(_ request: URLRequest, _ completion: @escaping Completion) -> URLSessionTask {
    let task = session.dataTask(with: request) { (data, response, error) in
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
