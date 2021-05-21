import Foundation

extension Filter {
    public var queryItems: [URLQueryItem] {
        let kindParams = kinds.map({ ("type", $0.rawValue) })
        let hostAppParams = hostExecutables.map({ ("host", $0) })
        let platformParams = platforms.map({ ("platform", $0) })

        let epochRange = dateRange.epochTimeRange

        var items: [URLQueryItem] = []

        if dateRange.lowerBound > Date(timeIntervalSince1970: 0.0) {
            items.append(URLQueryItem(name: "start_time", value: "\(epochRange.lowerBound)"))
        }

        if dateRange.upperBound < Date() {
            items.append(URLQueryItem(name: "end_time", value: "\(epochRange.upperBound)"))
        }

        let pairs = kindParams + hostAppParams + platformParams

        for (key, value) in pairs {
            items.append(URLQueryItem(name: key, value: value))
        }

        return items
    }
}
