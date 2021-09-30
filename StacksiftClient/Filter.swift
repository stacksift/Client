import Foundation

public struct Filter: Codable {
    public var title: String
    public var kinds: Set<String>
    public var hostExecutables: Set<String>
    public var builds: Set<String>
    public var versions: Set<String>
    public var osBuilds: Set<String>
    public var osVersions: Set<String>
    public var devices: Set<String>
    public var timeWindow: TimeWindow
    public var platforms: Set<String>
    public var organizations: Set<String>

    public init(title: String, kinds: Set<String> = Set(), hostExecutables: Set<String> = Set(), timeWindow: TimeWindow, platforms: Set<String> = Set(), organizations: Set<String> = Set()) {
        self.title = title
        self.kinds = kinds
        self.hostExecutables = hostExecutables
        self.builds = []
        self.versions = []
        self.timeWindow = timeWindow
        self.platforms = platforms
        self.organizations = organizations
        self.osBuilds = Set()
        self.osVersions = Set()
        self.devices = Set()
    }

    public static var newFilter: Filter = Filter(title: "New Filter", timeWindow: .lastYear)
}

extension Filter {
    public enum TimeWindow: Int, CaseIterable, Hashable, Codable, Comparable {
        case last24Hours
        case last7Days
        case last30Days
        case lastYear

        public static func < (lhs: Filter.TimeWindow, rhs: Filter.TimeWindow) -> Bool {
            return lhs.dateRange.lowerBound < rhs.dateRange.lowerBound
        }

        public var dateRange: Range<Date> {
            let now = Date()
            let secondsPerDay = 60 * 60 * 24

            let days: Int

            switch self {
            case .lastYear:
                days = 365
            case .last30Days:
                days = 30
            case .last7Days:
                days = 7
            case .last24Hours:
                days = 1
            }

            let seconds = days * secondsPerDay

            return now.addingTimeInterval(-Double(seconds))..<now
        }

        public var displayName: String {
            switch self {
            case .lastYear:
                return "Last Year"
            case .last30Days:
                return "Last 30 Days"
            case .last7Days:
                return "Last 7 Days"
            case .last24Hours:
                return "Last 24 Hours"
            }
        }
    }
}

extension Filter: Hashable {
}

extension Filter: Identifiable {
    public var id: String {
        return "\(hashValue)"
    }
}

extension Range where Bound == Date {
    public static var allTime = Date.distantPast..<Date.distantFuture

    public var epochTimeRange: Range<Int> {
        let start = Int(lowerBound.timeIntervalSince1970)
        let end = Int(upperBound.timeIntervalSince1970)

        return start..<end
    }
}

extension Filter {
    public static var defaultList: [Filter] = Filter.TimeWindow.allCases.sorted().map({
        return Filter(title: $0.displayName, timeWindow: $0)
    })
}

