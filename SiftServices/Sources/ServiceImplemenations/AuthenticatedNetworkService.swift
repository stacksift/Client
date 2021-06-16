import Foundation
import SiftServices
import SiftNetwork
import OAuthenticator
import KeychainAccess

public class AuthenticatedNeworkService {
    private lazy var authenticator: OAuthenticator = {
        let authHandler = OAuthFlowHandler(authorizationHost: AuthenticatedNeworkService.host,
                                           clientId: AuthenticatedNeworkService.clientId,
                                           clientPassword: AuthenticatedNeworkService.clientPassword,
                                           callbackURLScheme: AuthenticatedNeworkService.callbackURLScheme,
                                           scopes: AuthenticatedNeworkService.scopes)
        let config = AuthConfiguration(tokenURL: AuthenticatedNeworkService.loginURL,
                                       callbackURLScheme: AuthenticatedNeworkService.callbackURLScheme,
                                       loader: loader,
                                       loginStorage: self,
                                       flowHandler: authHandler)

        return OAuthenticator(config: config)
    }()

    let loader: URLLoader
    private var login: OAuthLogin?

    public init(loader: URLLoader) {
        self.loader = loader
    }
}

extension AuthenticatedNeworkService {
    private static let clientId = "4m6dp6bu89snr7s0prhp7dkj78"
    private static let clientPassword = "1m2a0q4s7t8q0ivoucoljldfthci6psc1f022621bao4lctmon7a"
    private static let callbackURLScheme = "stacksift-oauth-login"
    private static let scopes = ["openid", "profile"]
    private static let host = "authentication.stacksift.io"

    private static var scopeString: String {
        return scopes.joined(separator: " ")
    }

    private static var loginURL: URL {
        var loginURL = URLComponents()

        loginURL.scheme = "https"
        loginURL.host = host
        loginURL.path = "/login"
        loginURL.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "redirect_uri", value: "\(callbackURLScheme)://login")
        ]

        return loginURL.url!
    }
}


extension AuthenticatedNeworkService: NetworkService {
    public func response(for request: URLRequest) -> ResponsePublisher {
        authenticator.responsePublisher(for: request)
            .mapError { error -> URLError in
                switch (error) {
                case let urlError as URLError:
                    return urlError
                default:
                    print("unknown error: \(error)")
                    return URLError(.unknown)
                }
            }.eraseToAnyPublisher()
    }
}

extension AuthenticatedNeworkService: LoginStorage {
    public func storeLogin(_ login: OAuthLogin, completionHandler: @escaping (Error?) -> Void) {
        OperationQueue.main.addOperation {
            self.login = login

            let keychain = Keychain(service: "io.stacksift.token")

            try? keychain.remove("access")
            keychain["refresh"] = login.refreshToken

            completionHandler(nil)
        }
    }

    public func retrieveLogin(completionHandler: @escaping (Result<OAuthLogin, Error>) -> Void) {
        OperationQueue.main.addOperation {
            if let login = self.login {
                completionHandler(.success(login))
                return
            }

            let keychain = Keychain(service: "io.stacksift.token")

            guard let refreshToken = keychain["refresh"] else {
                completionHandler(.failure(OAuthenticatorError.unableToRetrieveLoginData))
                return
            }

            let login = OAuthLogin(accessToken: "invalid", refreshToken: refreshToken, validUntilDate: .distantPast)

            completionHandler(.success(login))
        }
    }
}
