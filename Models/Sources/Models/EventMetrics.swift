import Foundation

public struct EventMetrics: Codable {
    public var occurrences: Int
    public var users: Int
    public var hostApps: Int
    public var relationships: Int

    enum CodingKeys: String, CodingKey {
        case occurrences
        case users
        case hostApps = "host_apps"
        case relationships
    }

    public init(occurrences: Int = 0, users: Int = 0, hostApps: Int = 0, relationships: Int = 0) {
        self.occurrences = occurrences
        self.users = users
        self.hostApps = hostApps
        self.relationships = relationships
    }
}
