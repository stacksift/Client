import SwiftUI
import SiftServices
import Models

struct PathContentView: View {
    var entry: PathEntry
    var activeEntry: Binding<PathEntry?>
    @Environment(\.services) var services: Services

    var body: some View {
        switch entry {
        case .filter(let filter):
            FilterResultView(services: services, filter: filter, activeEntry: activeEntry)
        case .report(let reportId):
            ReportView(services: services, reportId: reportId, activeEntry: activeEntry)
        }
    }
}

