import Models
import SiftServices
import Combine
import Foundation

public class FilterResultsViewModel: ObservableObject {
    @Published public private(set) var results: [Event]

    let filter: Filter
    let services: Services
    private var cancellationToken: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()

    public init(services: Services, filter: Filter) {
        self.services = services
        self.results = []
        self.filter = filter

        NotificationCenter.default.publisher(for: .RefreshData)
            .receive(on: RunLoop.main)
            .sink { _ in
                self.reload()
            }
            .store(in: &subscriptions)
    }

    public func reload() {
        let url = URL(string: "https://api.stacksift.io")!
        var urlBuilder = URLComponents()

        urlBuilder.scheme = url.scheme
        urlBuilder.host = url.host

        urlBuilder.path = "/v1/events"

        urlBuilder.queryItems = filter.queryItems

        let request = URLRequest(url: urlBuilder.url!)

        self.cancellationToken = services.networkService
            .loadResource(request: request)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (events: [Event]?) in
                self.results = events ?? []
            })
    }

    var title: String {
        return "Filter Results: \(filter.title)"
    }
}
