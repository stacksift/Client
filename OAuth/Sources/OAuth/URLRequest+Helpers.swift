import Foundation

public extension URLRequest {
    enum HTTPHeader: String {
        case authorization = "Authorization"
        case contentType = "Content-Type"
        case accept = "Accept"
    }
}

public extension URLRequest {
    mutating func addValue(_ value: String, forHeader type: HTTPHeader) {
        addValue(value, forHTTPHeaderField: type.rawValue)
    }

    func authorizedRequest(with authorization: String) -> URLRequest {
        var request = self

        request.addValue(authorization, forHeader: .authorization)

        return request
    }
}
