import SwiftUI
import Models
import SiftServices

struct ReportView: View {
    @StateObject var model: ReportViewModel
    @EnvironmentObject var pathModel: PathViewModel
    var activeEntry: Binding<PathEntry?>

    init(services: Services, reportId: String, activeEntry: Binding<PathEntry?>) {
        self._model = StateObject(wrappedValue: ReportViewModel(services: services, reportId: reportId))
        self.activeEntry = activeEntry
    }

    var body: some View {
        VStack {
            NewReportTextView(text: model.text)
            EventTableView(events: model.events, activeEntry: activeEntry)
                .padding([.top], 10.0)
                .frame(maxHeight: 200.0)
        }
        .padding()
        .onAppear {
            model.reload()
        }
    }
}

#if DEBUG
import MockServiceImplemenations

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(services: Services.mock, reportId: "report-1", activeEntry: .constant(nil))
    }
}

#endif
