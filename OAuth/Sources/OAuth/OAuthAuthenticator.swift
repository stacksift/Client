import Foundation
import Combine
import CombineExt
import SiftNetwork
import KeychainAccess

public class OauthAuthenticator {
    public typealias Token = String
    public typealias TokenPublisher = AnyPublisher<Token, Error>
    public typealias RequestPublisher = AnyPublisher<URLRequest, Error>

    private enum State {
        case idle
        case token(Token)
    }

    private let credentialProvider: CredentialWindowProvider
    private let queue: OperationQueue
    private var state: State
    private var cancellables = Set<AnyCancellable>()
    private var activeTokenPublisher: TokenPublisher?
    private let configuration: OAuthConfiguration
    private let loader: NetworkService

    public init(loader: NetworkService, configuration: OAuthConfiguration) {
        self.loader = loader
        self.configuration = configuration
        self.state = .idle
        self.credentialProvider = CredentialWindowProvider()
        self.queue = OperationQueue()

        queue.maxConcurrentOperationCount = 1
        queue.name = "io.stacksift.Cliet.Authorization"
    }

    private func resetState() {
        queue.addOperation {
            self.state = .idle
            self.activeTokenPublisher = nil
        }
    }
}

extension OauthAuthenticator {
    private func storedTokenPublisher() -> AnyPublisher<Token, Error> {
        return Future { promise in
            OperationQueue.main.addOperation {
                let keychain = Keychain(service: self.configuration.keychainItemName)

                if let token = keychain["access"] {
                    promise(.success(token))
                } else {
                    promise(.failure(NSError(domain: "failed", code: 1)))
                }
            }


        }.eraseToAnyPublisher()
    }

    private func storeLoginResponse(_ token: Token) {
        let keychain = Keychain(service: configuration.keychainItemName)

        keychain["access"] = token
    }
}

extension OauthAuthenticator {
    private func userAuthenticationPublisher() -> AnyPublisher<Token, Error> {
        let authenticationConfig = configuration.webAuthenticationConfig

        return WebAuthenticationPublisher(configuration: authenticationConfig)
            .subscribe(on: OperationQueue.main)
            .tryMap { (callbackURL) -> URLRequest in
                return try self.configuration.accessURLRequest(with: callbackURL)
            }
            .flatMap { (request) -> AnyPublisher<Token, Error> in
                return self.loadTokenPublisher(with: request)
            }
            .eraseToAnyPublisher()
    }

    private func userAuthenticationTokenPublisher() -> AnyPublisher<Token, Error> {
        userAuthenticationPublisher()
            .map { (token) -> Token in
                self.storeLoginResponse(token)

                return token
            }
            .eraseToAnyPublisher()
    }

    private func loadTokenPublisher(with request: URLRequest) -> AnyPublisher<Token, Error> {
        return loader.response(for: request)
            .map(\.data)
            .tryMap { try self.configuration.login(from: $0) }
            .map(\.accessToken)
            .eraseToAnyPublisher()
    }
}

extension OauthAuthenticator {
    private func myTokenPublisher() -> TokenPublisher {
        storedTokenPublisher()
            .catch { (_) -> TokenPublisher in
                self.userAuthenticationTokenPublisher()
            }
            .subscribe(on: self.queue)
            .share(replay: 1)
            .eraseToAnyPublisher()
    }

    private func tokenPublisher() -> TokenPublisher {
        print("step: get or set activeTokenPublisher")

        if let active = self.activeTokenPublisher {
            print("step: returning active")
            return active
        }

        let publisher = storedTokenPublisher()
            .catch { (_) -> TokenPublisher in
                self.userAuthenticationTokenPublisher()
            }
            .subscribe(on: self.queue)
            .share(replay: 1)
            .eraseToAnyPublisher()

        self.activeTokenPublisher = publisher

        print("step: built a new publisher")

        return publisher
    }

    private func getTokenPublisher() -> TokenPublisher {
        Future<TokenPublisher, Never> { promise in
            self.queue.addOperation {
                let publisher = self.tokenPublisher()

                print("step: getting tokenPublisher")

                promise(.success(publisher))
            }
        }
        .flatMap { $0 }
        .eraseToAnyPublisher()
    }

    public func authorizedRequestPublisher(_ request: URLRequest) -> AnyPublisher<URLRequest, Error> {
        getTokenPublisher()
            .flatMap { (code) -> Just<URLRequest> in
                let authedRequest = request.authorizedRequest(with: code)

                print("step: add authentication")

                return Just<URLRequest>(authedRequest)
            }
            .eraseToAnyPublisher()
    }
}

