import Cocoa
import Combine
import ViewPlus
import SwiftUI

class EventDetailsViewController: XiblessViewController<NSView> {
    private let headerView: NSHostingView<StacktraceHeaderView>
    private let framesViewController: StacktraceFramesViewController
    private let extrasViewController: EventExtrasViewController
    private let metricsViewController: EventMetricsViewController

    var report: Report? {
        get { return representedObject as? Report }
        set { representedObject = newValue }
    }

    var metrics: [EventOccurrenceMetrics]? {
        get { return metricsViewController.metrics }
        set { metricsViewController.metrics = newValue }
    }

    override var representedObject: Any? {
        didSet {
            headerView.rootView = traceHeader

            let frames = report?.blamedTrace?.frames ?? []
            let displayableFrames = frames.map { (frame) -> DisplayableFrame in
                let events = report?.events(for: frame)
                let highlighted = events?.isEmpty == false

                return DisplayableFrame(frame: frame, highlighted: highlighted)
            }

            framesViewController.frames = displayableFrames

            let set = report?.relationshipEventSet ?? .empty
            
            extrasViewController.content = set
        }
    }

    var viewEventsAction: ((EventSet) -> Void)? {
        get { extrasViewController.viewEventsAction }
        set { extrasViewController.viewEventsAction = newValue }
    }

    override init() {
        self.headerView = NSHostingView(rootView: StacktraceHeaderView(title: "title", subtitle: "subtitle", extraInfo: "extra"))
        self.framesViewController = StacktraceFramesViewController()
        self.extrasViewController = EventExtrasViewController()
        self.metricsViewController = EventMetricsViewController()

        super.init()
    }

    override func loadView() {
        self.view = NSView()

        let framesView = framesViewController.view
        let extrasView = extrasViewController.view
        let metricsView = metricsViewController.view
        let border = NSBox()

        border.boxType = .separator

        view.subviews = [headerView, framesView, border, extrasView, metricsView]
        view.subviewsUseAutoLayout = true

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10.0),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10.0),
            headerView.trailingAnchor.constraint(equalTo: extrasView.leadingAnchor, constant: -10.0),

            framesView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10.0),
            framesView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0),
            framesView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            framesView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            extrasView.topAnchor.constraint(equalTo: headerView.topAnchor),
            extrasView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150.0),
            extrasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
            extrasView.widthAnchor.constraint(equalToConstant: 250.0),
            extrasView.bottomAnchor.constraint(equalTo: metricsView.topAnchor, constant: 10.0),

            metricsView.bottomAnchor.constraint(equalTo: framesView.bottomAnchor),
            metricsView.leadingAnchor.constraint(equalTo: extrasView.leadingAnchor),
            metricsView.trailingAnchor.constraint(equalTo: extrasView.trailingAnchor),

            border.topAnchor.constraint(equalTo: extrasView.topAnchor),
            border.bottomAnchor.constraint(equalTo: extrasView.bottomAnchor),
            border.leadingAnchor.constraint(equalTo: extrasView.leadingAnchor, constant: -1.0),
            border.widthAnchor.constraint(equalToConstant: 1.0),
        ])
    }

    private var traceHeader: StacktraceHeaderView {
        return StacktraceHeaderView(title: traceTitle,
                                    subtitle: traceSubtitle,
                                    extraInfo: traceExtraInfo)
    }

    private var traceTitle: String {
        let idx = report?.crashedThreadIndex ?? 0

        return "Crashed Thread: \(idx)"
    }

    private var traceSubtitle: String {
        if let machExc = report?.machException {
            return machExc.name
        }

        if let signal = report?.signal {
            return signal.name
        }

        return ""
    }

    private var traceExtraInfo: String {
        return report?.terminationReason ?? ""
    }
}
