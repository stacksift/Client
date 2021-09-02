import Cocoa
import ViewPlus
import Combine

class EventsViewController: XiblessViewController<NSView> {
    enum Content {
        case filter(Filter)
        case eventSet(Event, EventSet)
    }

    let apiClient: APIClient

    private let eventListViewController: EventListViewController
    private let graphViewController: EventGraphViewController
    private var cancellables: Set<AnyCancellable>

    init(apiClient: APIClient, content: Content) {
        self.apiClient = apiClient
        self.cancellables = Set()

        self.eventListViewController = EventListViewController()
        self.graphViewController = EventGraphViewController()

        super.init()

        self.content = content
    }

    var content: Content {
        get { representedObject as! Content }
        set {
            switch newValue {
            case .eventSet(let event, let set):
                let sortedEvents = set.events.sorted(by: { (a, b) in
                    return a.metrics.occurrences > b.metrics.occurrences
                })

                let sortedSet = EventSet(events: sortedEvents, visibleIds: set.visibleIds)
                
                representedObject = Content.eventSet(event, sortedSet)
            default:
                representedObject = newValue
            }
        }
    }

    override var representedObject: Any? {
        didSet {
            precondition(representedObject is Content)

            reload()
        }
    }

    override func loadView() {
        self.view = NSView()

        let listView = eventListViewController.contentView
        let graphView = graphViewController.contentView

        view.subviews = [graphView, listView]
        view.subviewsUseAutoLayout = true

        NSLayoutConstraint.activate([
            graphView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10.0),
            graphView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
            graphView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
            graphView.heightAnchor.constraint(equalToConstant: 300.0),

            listView.topAnchor.constraint(equalTo: graphView.bottomAnchor, constant: 10.0),
            listView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
            listView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
            listView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0),
        ])
    }

    override func viewWillAppear() {
        reload()
    }

    private func reload() {
        switch content {
        case .filter(let filter):
            apiClient.filterResultsPublisher(filter)
                .receive(on: RunLoop.main)
                .sink(receiveValue: { (newValue: [Event]?) in
                    self.eventListViewController.events = newValue ?? []
                })
                .store(in: &cancellables)

            apiClient.timeseriesPublisher(filter)
                .receive(on: RunLoop.main)
                .sink(receiveValue: { (newValue: [TimeseriesPoint]?) in
                    self.graphViewController.points = newValue ?? []
                })
                .store(in: &cancellables)
        case .eventSet(_, let set):
            self.graphViewController.points = []
            self.eventListViewController.events = set.events
        }
    }

    var eventSelectedHandler: ((Event) -> Void)? {
        get { eventListViewController.eventSelectedHandler }
        set { eventListViewController.eventSelectedHandler = newValue }
    }
}
