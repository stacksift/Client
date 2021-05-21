import Foundation
import SiftServices
import SiftNetwork
import Combine

public class URLKeyedMockNetworkService {
    public typealias Response = Result<ResponsePublisher.Output, ResponsePublisher.Failure>
    public var responses: [String : Response]

    public init() {
        self.responses = [:]
    }

    public func addMockResponse(_ string: String, json: String) {
        let data = json.data(using: .utf8)!
        let headers = [
            "Content-Type": "application/json",
            "Content-Length": "\(data.count)"
        ]

        addMockResponse(string, data: data, headers: headers)
    }

    public func addMockResponse(_ string: String, data: Data, headers: [String: String] = [:]) {
        let response = HTTPURLResponse(url: URL(string: string)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!

        responses[string] = .success((data: data, response: response))
    }
}

extension URLKeyedMockNetworkService: NetworkService {
    private func storedResponse(for request: URLRequest) -> Response? {
        guard let path = request.url?.absoluteString else {
            return nil
        }

        return responses[path]
    }

    public func response(for request: URLRequest) -> ResponsePublisher {
        let urlString = request.url?.absoluteString ?? ""

        return Deferred {
            Future<ResponsePublisher.Output, ResponsePublisher.Failure> { promise in
                OperationQueue.main.addOperation {
                    guard let response = self.storedResponse(for: request) else {
                        print("unhandled path: \(urlString)")

                        promise(.failure(URLError(.unsupportedURL, userInfo: ["Simulated": true])))
                        return
                    }

                    promise(response)
                }
            }
        }.eraseToAnyPublisher()
    }
}
