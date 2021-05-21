import SwiftUI
import Models
import SiftServices

struct SidebarLinkView: View {
    var entry: PathEntry
    private var root: Bool
    @Binding var activeEntry: PathEntry?
    @EnvironmentObject var contentModel: PathViewModel

    init(entry: PathEntry, activeEntry: Binding<PathEntry?>) {
        self.entry = entry
        self.root = false
        self._activeEntry = activeEntry
    }

    init(rootFilter: Filter, activeEntry: Binding<PathEntry?>) {
        self.entry = .filter(rootFilter)
        self.root = true
        self._activeEntry = activeEntry
    }

    private func appeared() {
        if root {
            contentModel.removeAllEntries()
        }
    }

    var imageName: String {
        switch entry {
        case .report:
            return "doc.text.fill"
        case .filter:
            return "line.horizontal.3.decrease.circle"
        }
    }
    
    var body: some View {
        let dest = LazyView(PathContentView(entry: entry, activeEntry: $activeEntry)
                                .onAppear(perform: appeared))

        NavigationLink(destination: dest, tag: entry, selection: $activeEntry) {
            Label(entry.title, systemImage: imageName)
        }
    }
}

struct SidebarContentView: View {
    @StateObject var filterModel: FilterListViewModel
    @EnvironmentObject var pathModel: PathViewModel
    @State var activeEntry: PathEntry?

    init() {
        self._filterModel = StateObject(wrappedValue: FilterListViewModel())
    }

    private var filters: [Filter] {
        return filterModel.filters
    }

    private var pathEntries: [PathEntry] {
        return pathModel.entries
    }

    var body: some View {
        List {
            Section(header: Text("Filters")) {
                ForEach(filters, id: \.id) { filter in
                    SidebarLinkView(rootFilter: filter, activeEntry: $activeEntry)
                }
            }
            Section(header: Text("Path")) {
                ForEach(pathEntries, id: \.id) { entry in
                    SidebarLinkView(entry: entry, activeEntry: $activeEntry)
                }
            }
        }
        .onAppear {
            filterModel.reload()
        }
    }
}

#if DEBUG
struct SidebarContentView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarContentView()
    }
}
#endif
