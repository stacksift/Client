import Foundation
import Combine

public protocol NetworkService {
    typealias Output = URLSession.DataTaskPublisher.Output
    typealias Failure = URLSession.DataTaskPublisher.Failure
    typealias ResponsePublisher = AnyPublisher<Output, Failure>

    func response(for request: URLRequest) -> ResponsePublisher
}

public enum HTTPResponse {
    case rejected(response: HTTPURLResponse)
    case retry(response: HTTPURLResponse, after: TimeInterval)
    case success(response: HTTPURLResponse, data: Data)
}

public extension Publisher where Output == NetworkService.Output, Failure == NetworkService.Failure {
    func HTTPResponse() -> AnyPublisher<HTTPResponse, Error> {
        tryMap { (output) -> HTTPResponse in
            guard let response = output.response as? HTTPURLResponse else {
                throw NSError(domain: "blah", code: 1)
            }

            switch response.statusCode {
            case 200..<299:
                return .success(response: response, data: output.data)
            default:
                return .rejected(response: response)
            }

        }
        .eraseToAnyPublisher()
    }
}

public extension NetworkService {
    func dataPublisher(for request: URLRequest) -> AnyPublisher<Data, Error> {
        response(for: request)
        .HTTPResponse()
        .tryMap({ resp -> Data in
            switch resp {
            case .rejected(let response):
                throw NSError(domain: "blah", code: 5, userInfo: ["Response": response])
            case .retry(let response, let after):
                throw NSError(domain: "blah", code: 6, userInfo: ["Response": response, "after": String(after)])
            case .success(_, let data):
                return data
            }
        })
        .eraseToAnyPublisher()
    }

    func loadResource<A: Decodable>(request: URLRequest) -> AnyPublisher<A?, Never> {
        return dataPublisher(for: request)
            .tryMap({ try JSONDecoder().decode(A.self, from: $0) })
            .catch({ error -> Just<A?> in
                print("error: \(error)")

                return Just(nil)
            })
            .eraseToAnyPublisher()
    }
}
