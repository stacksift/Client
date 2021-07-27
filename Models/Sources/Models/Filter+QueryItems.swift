import Foundation

extension Filter {
    public var queryItems: [URLQueryItem] {
        let kindParams = kinds.map({ ("type", $0) })
        let hostAppParams = hostExecutables.map({ ("host", $0) })
        let platformParams = platforms.map({ ("platform", $0) })
        let organizationParams = organizations.map({ ("organization", $0) })
        let buildParams = builds.map({ ("build", $0) })
        let versionParams = versions.map({ ("version", $0) })

        let epochRange = timeWindow.dateRange.epochTimeRange

        var items: [URLQueryItem] = []

        if timeWindow.dateRange.lowerBound > Date(timeIntervalSince1970: 0.0) {
            items.append(URLQueryItem(name: "start_time", value: "\(epochRange.lowerBound)"))
        }

        if timeWindow.dateRange.upperBound < Date() {
            items.append(URLQueryItem(name: "end_time", value: "\(epochRange.upperBound)"))
        }

        let pairs = kindParams + hostAppParams + platformParams + organizationParams + buildParams + versionParams

        for (key, value) in pairs {
            items.append(URLQueryItem(name: key, value: value))
        }

        return items
    }
}
