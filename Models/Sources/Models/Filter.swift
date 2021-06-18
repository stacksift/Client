import Foundation

public struct Filter {
    public var title: String
    public var kinds: Set<String>
    public var hostExecutables: [String]
    public var dateRange: Range<Date>
    public var platforms: [String]
    public var organizations: [String]

    public init(title: String, kinds: Set<String> = Set(), hostExecutables: [String] = [], dateRange: Range<Date>, platforms: [String] = [], organizations: [String] = []) {
        self.title = title
        self.kinds = kinds
        self.hostExecutables = hostExecutables
        self.dateRange = dateRange
        self.platforms = platforms
        self.organizations = organizations
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
    private static func daysAgo(_ days: Int) -> Range<Date> {
        let now = Date()
        let secondsPerDay = 60 * 60 * 24
        let seconds = days * secondsPerDay

        return now.addingTimeInterval(-Double(seconds))..<now
    }

    public static var day = daysAgo(1)
    public static var week = daysAgo(7)
    public static var month = daysAgo(30)
    
    public static var allTime = Date.distantPast..<Date.distantFuture

    public var epochTimeRange: Range<Int> {
        let start = Int(lowerBound.timeIntervalSince1970)
        let end = Int(upperBound.timeIntervalSince1970)

        return start..<end
    }
}

extension Filter {
    public static var defaultList: [Filter] = [
        Filter(title: "All Time", dateRange: .allTime),
        Filter(title: "Last 30 Days", dateRange: .month),
        Filter(title: "Last 7 Days", dateRange: .week),
        Filter(title: "Today", dateRange: .day),
    ]
}
