import Foundation

public struct EventOccurrenceMetrics: Codable {
    public struct VersionMetric: Codable {
        public var version: VersionPair
        public var count: Int
    }

    public struct ModelMetric: Codable {
        public var model: String
        public var count: Int
    }

    public var hostVersions: [VersionMetric]
    public var osVersions: [VersionMetric]
    public var deviceModels: [ModelMetric]
    public var signature: String

    enum CodingKeys: String, CodingKey {
        case hostVersions = "host_versions"
        case osVersions = "os_versions"
        case deviceModels = "device_models"
        case signature
    }
}
