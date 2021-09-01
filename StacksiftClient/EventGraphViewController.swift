import Cocoa
import ViewPlus
import Combine
import SwiftUI

class EventGraphViewController: XiblessViewController<NSHostingView<ChartView>> {
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        
        self.points = []
    }

    var points: [TimeseriesPoint] {
        get { representedObject as! [TimeseriesPoint] }
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            precondition(representedObject is [TimeseriesPoint])

            reloadGraph()
        }
    }

    private var chartPoints: [CGPoint] {
        return points.map({ $0.countPoint })
    }

    override func loadView() {
        self.view = NSHostingView(rootView: ChartView(data: chartPoints))
    }

    private func reloadGraph() {
        contentView.rootView = ChartView(data: chartPoints)
    }
}
