import Foundation
import SiftServices
import SiftNetwork
import Combine

public class MockNetworkService {
    public var responses: [Result<ResponsePublisher.Output, ResponsePublisher.Failure>]

    public init() {
        self.responses = []
    }

    public func addMockResponse(_ string: String, json: String) {
        let data = json.data(using: .utf8)!
        let headers = [
            "Content-Type": "application/json",
            "Content-Length": "\(data.count)"
        ]

        let response = HTTPURLResponse(url: URL(string: string)!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!

        responses.append(.success((data: data, response: response)))
    }

    public func addMockResponse<T: Encodable>(_ string: String, encodable: T) {
        let json = try! JSONEncoder().encode(encodable)
        let jsonString = String(data: json, encoding: .utf8)!

        addMockResponse(string, json: jsonString)
    }
}

extension MockNetworkService: NetworkService {
    public func response(for request: URLRequest) -> ResponsePublisher {
        return Deferred {
            Future<ResponsePublisher.Output, ResponsePublisher.Failure> { promise in
                OperationQueue.main.addOperation {
                    guard self.responses.isEmpty == false else {
                        promise(.failure(URLError(.resourceUnavailable, userInfo: ["Simulated": true])))
                        return
                    }

                    let next = self.responses.removeFirst()

                    promise(next)
                }
            }.eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
}
