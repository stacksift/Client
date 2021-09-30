import Cocoa
import ViewPlus
import SwiftUI

class FilterEditViewController: XiblessViewController<NSHostingView<FilterEditView>> {
    private var filter: Filter
    var responseHandler: (NSApplication.ModalResponse, Filter) -> Void

    init(filter: Filter) {
        self.filter = filter
        self.responseHandler = { (_, _) in }

        super.init()
    }

    private var filterBinding:  Binding<Filter> {
        return Binding<Filter> {
            return self.filter
        } set: { newValue in
            self.filter = newValue
        }
    }
    override func loadView() {
        let editView = FilterEditView(filter: filterBinding) { [unowned self] response in
            self.responseHandler(response, filter)
        }

        self.view = NSHostingView(rootView: editView)
    }
}
