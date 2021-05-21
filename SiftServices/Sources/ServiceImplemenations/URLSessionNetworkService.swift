import Foundation
import SiftNetwork
import SiftServices

public class URLSessionNetworkService: NSObject {
    private lazy var session: URLSession = {
        let sess = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)

        return sess
    }()

    public override init() {
    }
}

extension URLSessionNetworkService: URLSessionDelegate {

}

extension URLSessionNetworkService: NetworkService {
    public func response(for request: URLRequest) -> ResponsePublisher {
        session.dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

