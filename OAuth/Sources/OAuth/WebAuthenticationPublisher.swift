import Foundation
import Combine
import AuthenticationServices

enum WebAuthenticationSessionError: Error {
    case resultInvalid
}

extension ASWebAuthenticationSession {
    public convenience init(url: URL, callbackURLScheme: String? = nil, completionHandler: @escaping (Result<URL, Error>) -> Void) {
        self.init(url: url, callbackURLScheme: callbackURLScheme, completionHandler: { (resultURL, error) in
            switch (resultURL, error) {
            case (_, let error?):
                completionHandler(.failure(error))
            case (let callbackURL?, nil):
                completionHandler(.success(callbackURL))
            default:
                completionHandler(.failure(WebAuthenticationSessionError.resultInvalid))
            }
        })
    }
}

public protocol WebAuthenticationSessionConfiguring {
    func configureAuthenticationSession(_ session: ASWebAuthenticationSession)
}

public struct WebAuthenticationConfiguration {
    let url: URL
    let scheme: String?
    let sessionConfigurator: WebAuthenticationSessionConfiguring
}

public class WebAuthenticationPublisher: Publisher {
    public typealias Output = URL
    public typealias Failure = Error

    public let configuration: WebAuthenticationConfiguration

    public init(configuration: WebAuthenticationConfiguration) {
        self.configuration = configuration
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = WebAuthenticationSubscription(configuration: configuration, subscriber: subscriber)

        subscriber.receive(subscription: subscription)
    }
}

private extension WebAuthenticationPublisher {
    final class WebAuthenticationSubscription<S: Subscriber>: Subscription where S.Input == Output, S.Failure == Failure {
        private var subscriber: S?

        private let configuration: WebAuthenticationConfiguration
        private var authSession: ASWebAuthenticationSession?

        init(configuration: WebAuthenticationConfiguration, subscriber: S) {
            self.configuration = configuration
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            let config = self.configuration

            OperationQueue.main.addOperation {
                if self.authSession != nil {
                    return
                }

                let url = config.url
                let scheme = config.scheme

                let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme, completionHandler: { [weak self] (result) in
                    self?.handleSessionResult(result)
                })

                self.authSession = session

                config.sessionConfigurator.configureAuthenticationSession(session)

                session.start()
            }
        }

        func cancel() {
            OperationQueue.main.addOperation {
                self.authSession?.cancel()
            }

            subscriber = nil
        }

        private func handleSessionResult(_ result: Result<URL, Error>) {
            switch result {
            case .failure(let error):
                subscriber?.receive(completion: .failure(error))
            case .success(let resultURL):
                _ = self.subscriber?.receive(resultURL)
            }
        }
    }
}

struct SessionConfiguration {
    let windowProvider = CredentialWindowProvider()
}

extension SessionConfiguration: WebAuthenticationSessionConfiguring {
    func configureAuthenticationSession(_ session: ASWebAuthenticationSession) {
        session.prefersEphemeralWebBrowserSession = true
        session.presentationContextProvider = windowProvider
    }
}
