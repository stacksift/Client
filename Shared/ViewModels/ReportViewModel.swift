import SiftServices
import Combine
import Foundation
import Models

class ReportViewModel: ObservableObject {
    let reportId: String
    let services: Services
    private var cancellationToken: AnyCancellable?

    @Published public private(set) var text: NSAttributedString
    @Published public private(set) var events: [Event]
    
    init(services: Services, reportId: String) {
        self.services = services
        self.reportId = reportId
        self.text = NSAttributedString()
        self.events = []
    }

    private func update(with report: Report?) {
        guard let report = report else {
            self.text = NSAttributedString(string: "nothing")
            return
        }

        self.events = report.relationships

        DispatchQueue.global().async {
            let renderValue = try? report.renderReportCrash()

            DispatchQueue.main.async {
                self.text = renderValue ?? NSAttributedString(string: "failed")
            }
        }
    }

    func reload() {
        let url = URL(string: "https://api.stacksift.io")!
        var urlBuilder = URLComponents()

        urlBuilder.scheme = url.scheme
        urlBuilder.host = url.host

        urlBuilder.path = "/v1/reports/" + reportId

        var request = URLRequest(url: urlBuilder.url!)

        request.addValue("application/json", forHeader: .accept)

        self.cancellationToken = services.networkService
            .loadResource(request: request)
            .receive(on: RunLoop.main)
            .sink(receiveValue: {
                self.update(with: $0)
            })
    }
}
