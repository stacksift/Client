import Foundation

public enum OAuthError: Error {
    case callbackURLInvalid
}

public struct OAuthLogin {
    public typealias Token = String

    public var accessToken: Token
    public var refreshToken: Token
    public var validUntilDate: Date
}

public protocol OAuthConfiguration {
    var webAuthenticationConfig: WebAuthenticationConfiguration { get }

    func accessURLRequest(with callback: URL) throws -> URLRequest
    func login(from data: Data) throws -> OAuthLogin
}

struct LoginResponse: Decodable {
    var idToken: String
    var accessToken: String
    var refreshToken: String
    var expiresIn: Int
    var tokenType: String
    private let createdDate = Date()

    enum CodingKeys: String, CodingKey {
        case idToken = "id_token"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }

    var expiryDate: Date {
        return createdDate.addingTimeInterval(TimeInterval(expiresIn))
    }

    var oauthLogin: OAuthLogin {
        return OAuthLogin(accessToken: accessToken, refreshToken: refreshToken, validUntilDate: expiryDate)
    }
}

public struct BasicOauthConfiguration {
    public let clientId: String
    public let clientPassword: String
    public let callbackURLScheme = "stacksift-oauth-login"
    public let scopes: [String]
    let authenticationSessionConfigurator = SessionConfiguration()

    public init(clientId: String, clientPassword: String, scopes: [String]) {
        self.clientId = clientId
        self.clientPassword = clientPassword
        self.scopes = scopes
    }

    private var scopeString: String {
        return scopes.joined(separator: " ")
    }

    private var loginURL: URL {
        var loginURL = URLComponents()

        loginURL.scheme = "https"
        loginURL.host = "authentication.stacksift.io"
        loginURL.path = "/login"
        loginURL.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "redirect_uri", value: "\(callbackURLScheme)://login")
        ]

        return loginURL.url!
    }

    private func codeFromCallback(_ url: URL) throws -> String {
        // stacksift-oauth-login://login?code=edbcdc2f-4ba1-4eb6-938c-877324ea3d57
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        guard components?.scheme == callbackURLScheme else {
            throw OAuthError.callbackURLInvalid
        }

        guard components?.host == "login" else {
            throw OAuthError.callbackURLInvalid
        }

        let codeItem = components?.queryItems?.first(where: { $0.name == "code" })

        guard let value = codeItem?.value else {
            throw OAuthError.callbackURLInvalid
        }

        return value
    }

    private func tokenURL(with callbackURL: URL) throws -> URL {
        let code = try codeFromCallback(callbackURL)
        var urlBuilder = URLComponents()

        urlBuilder.scheme = "https"
        urlBuilder.host = "authentication.stacksift.io"
        urlBuilder.path = "/oauth2/token"
        urlBuilder.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "redirect_uri", value: "\(callbackURLScheme)://login"),
            URLQueryItem(name: "code", value: code),
        ]

        guard let url = urlBuilder.url else {
            throw OAuthError.callbackURLInvalid
        }

        return url
    }

    private var authorizationHeader: String {
        let string = "\(clientId):\(clientPassword)"
        let encodedString = string.data(using: .utf8)?.base64EncodedString() ?? ""

        return "Basic \(encodedString)"
    }
}

extension BasicOauthConfiguration: OAuthConfiguration {
    public var webAuthenticationConfig: WebAuthenticationConfiguration {
        WebAuthenticationConfiguration(url: loginURL,
                                       scheme: callbackURLScheme,
                                       sessionConfigurator: authenticationSessionConfigurator)
    }

    public func accessURLRequest(with callback: URL) throws -> URLRequest {
        let url = try tokenURL(with: callback)

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        request.addValue(authorizationHeader, forHeader: .authorization)
        request.addValue("application/x-www-form-urlencoded", forHeader: .contentType)
        request.addValue("application/json", forHeader: .accept)

        return request
    }

    public func login(from data: Data) throws -> OAuthLogin {
        return try JSONDecoder().decode(LoginResponse.self, from: data).oauthLogin
    }
}
