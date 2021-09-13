import Cocoa
import ViewPlus
import Combine

class EventContentViewController: XiblessViewController<NSView> {
    let apiClient: APIClient
    let event: Event
    let textViewController: EventTextViewController
    let detailsViewController: EventDetailsViewController
    private var cancellables = Set<AnyCancellable>()

    init(apiClient: APIClient, event: Event) {
        self.event = event
        self.apiClient = apiClient
        self.textViewController = EventTextViewController()
        self.detailsViewController = EventDetailsViewController()

        super.init()
    }

    var report: Report? {
        get { return representedObject as? Report }
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            let renderValue = try? report?.renderReportCrash()

            textViewController.text = renderValue ?? NSAttributedString(string: "failed")

            detailsViewController.report = report

            reloadMetrics()
        }
    }

    var viewEventsAction: ((EventSet) -> Void)? {
        get { detailsViewController.viewEventsAction }
        set { detailsViewController.viewEventsAction = newValue }
    }

    override func loadView() {
        self.view = NSView()

        let tabView = NSTabView()

        let detailsItem = NSTabViewItem(viewController: detailsViewController)
        detailsItem.label = "Details"

        tabView.addTabViewItem(detailsItem)

        let textItem = NSTabViewItem(viewController: textViewController)
        textItem.label = "Report Text"

        tabView.addTabViewItem(textItem)

        view.subviews = [tabView]
        view.subviewsUseAutoLayout = true

        NSLayoutConstraint.activate([
            tabView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10.0),
            tabView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0),
            tabView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
            tabView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
        ])
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        reloadReport()
    }

    private func reloadReport() {
        apiClient.reportPublisher(event.reportId)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (newValue: Report?) in
                self.report = newValue
            })
            .store(in: &cancellables)
    }

    private func reloadMetrics() {
        guard let report = report else { return }

        apiClient.eventMetricsPublisher(for: report)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (newValue: [EventOccurrenceMetrics]?) in
                self.detailsViewController.metrics = newValue
            })
            .store(in: &cancellables)
    }
}
