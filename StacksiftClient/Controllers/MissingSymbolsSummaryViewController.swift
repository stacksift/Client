import Cocoa
import ViewPlus
import Combine
import SwiftUI

class MissingSymbolsSummaryViewController: XiblessViewController<NSView> {
    let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()
    private lazy var summaryView = {
        return NSHostingView(rootView: MissingSymbolsSummaryView(count: 0, action: { [unowned self] in
            let controller = MissingSymbolsDetailsViewController()

            controller.missingSymbols = self.missingSymbols

            self.presentAsSheet(controller)
        }))
    }()

    init(apiClient: APIClient) {
        self.apiClient = apiClient

        super.init()
    }

    override func loadView() {
        self.view = NSView()

        summaryView.isHidden = true

        view.subviews = [summaryView]
        view.subviewsUseAutoLayout = true

        NSLayoutConstraint.activate([
            summaryView.topAnchor.constraint(equalTo: view.topAnchor),
            summaryView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        reloadReport()
    }

    private func reloadReport() {
        apiClient.missingSymbolsPublisher()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (newValue: [MissingSymbol]?) in
                self.missingSymbols = newValue ?? []
            })
            .store(in: &cancellables)
    }

    var missingSymbols: [MissingSymbol] {
        get { return representedObject as? [MissingSymbol] ?? [] }
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            let count = missingSymbols.count

            summaryView.rootView.count = count
            summaryView.isHidden = count <= 0
        }
    }
}
