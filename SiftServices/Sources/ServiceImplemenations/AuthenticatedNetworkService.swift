import Foundation
import Combine
import AuthenticationServices
import SiftServices
import SiftNetwork
import OAuth

public class AuthenticatedNeworkService {
    private let authenticator: OauthAuthenticator
    private let networkService: NetworkService

    public init(configuration: OAuthConfiguration) {
        let oathService = URLSessionNetworkService()
        self.authenticator = OauthAuthenticator(loader: oathService, configuration: configuration)

        self.networkService = URLSessionNetworkService()
    }
}

extension AuthenticatedNeworkService: NetworkService {
    public func response(for request: URLRequest) -> ResponsePublisher {
        authenticator.authorizedRequestPublisher(request)
            .mapError({ (error) -> URLError in
                Swift.print("mapping error: \(error)")
                return URLError(.userAuthenticationRequired)
            })
            .flatMap { (urlRequest) -> ResponsePublisher in
                Swift.print("starting authenticated load: \(urlRequest)")
                return self.networkService.response(for: urlRequest)
            }
            .eraseToAnyPublisher()
    }
}
