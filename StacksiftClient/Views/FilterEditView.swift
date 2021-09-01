import SwiftUI

struct FilterEditView: View {
    @Binding var filter: Filter

    var responseHandler: (NSApplication.ModalResponse) -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: 10.0) {
            FilterEditForm(filter: _filter)
            HStack(alignment: .center, spacing: 10.0) {
                Button("Cancel") {
                    self.responseHandler(.cancel)
                }
                    .keyboardShortcut(.cancelAction)
                Button("OK") {
                    self.responseHandler(.OK)
                }
                    .keyboardShortcut(.defaultAction)
            }

        }
        .padding()
    }
}

struct FilterEditView_Previews: PreviewProvider {
    static var previews: some View {
        FilterEditView(filter: .constant(Filter(title: "title", timeWindow: .lastYear)), responseHandler: { _ in })
    }
}
