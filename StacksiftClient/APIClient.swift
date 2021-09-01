import Foundation
import Combine

class APIClient {
    let networkService: NetworkService
    private var cancellables: Set<AnyCancellable>

    init(networkService: NetworkService) {
        self.networkService = networkService
        self.cancellables = Set()
    }

    private var url: URL {
        return URL(string: "https://api.stacksift.io")!
    }
}

extension APIClient {
    func filterResultsPublisher(_ filter: Filter) -> AnyPublisher<[Event]?, Never> {
        var urlBuilder = URLComponents()

        urlBuilder.scheme = url.scheme
        urlBuilder.host = url.host

        urlBuilder.path = "/v1/events"

        urlBuilder.queryItems = filter.queryItems

        let request = URLRequest(url: urlBuilder.url!)

        return networkService
            .loadResource(request: request)
    }

    func timeseriesPublisher(_ filter: Filter) -> AnyPublisher<[TimeseriesPoint]?, Never> {
        var urlBuilder = URLComponents()

        urlBuilder.scheme = url.scheme
        urlBuilder.host = url.host

        urlBuilder.path = "/v1/events_timeseries"

        urlBuilder.queryItems = filter.queryItems

        let request = URLRequest(url: urlBuilder.url!)

        return networkService
            .loadResource(request: request)
    }

    func reportPublisher(_ reportId: String) -> AnyPublisher<Report?, Never> {
        var urlBuilder = URLComponents()

        urlBuilder.scheme = url.scheme
        urlBuilder.host = url.host

        urlBuilder.path = "/v1/reports/" + reportId

        var request = URLRequest(url: urlBuilder.url!)

        request.addValue("application/json", forHeader: .accept)

        return networkService
            .loadResource(request: request)
    }
}

extension Filter {
    var queryItems: [URLQueryItem] {
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
