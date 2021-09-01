import Foundation

public struct TimeseriesPoint {
    public var devices: Int
    public var count: Int
    public var timeMillis: Int

    public var date: Date {
        return Date(timeIntervalSince1970: Double(timeMillis/1000))
    }

    public var countPoint: CGPoint {
        return CGPoint(x: date.timeIntervalSince1970, y: Double(count))
    }
}

extension TimeseriesPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case devices
        case count
        case timeMillis = "time"
    }
}
