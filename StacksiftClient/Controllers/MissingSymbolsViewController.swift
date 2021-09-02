import Cocoa
import ViewPlus
import Combine
import SwiftUI

class MissingSymbolsSummaryViewController: XiblessViewController<NSHostingView<MissingSymbolsSummaryView>> {
    let apiClient: APIClient
    private var cancellables = Set<AnyCancellable>()

    init(apiClient: APIClient) {
        self.apiClient = apiClient

        super.init()
    }

    override func loadView() {
        self.view = NSHostingView(rootView: MissingSymbolsSummaryView(count: 0))

//        view.isHidden = true
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        reloadReport()
    }

    private func reloadReport() {
        apiClient.missingSymbolsPublisher()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (newValue: [MissingSymbol]?) in
                self.missingSymbols = newValue
            })
            .store(in: &cancellables)
    }

    var missingSymbols: [MissingSymbol]? {
        get { return representedObject as? [MissingSymbol] }
        set { representedObject = newValue }
    }

    override var representedObject: Any? {
        didSet {
            let count = missingSymbols?.count ?? 0
            self.contentView.rootView = MissingSymbolsSummaryView(count: count)

            self.view.isHidden = count <= 0
        }
    }
}
