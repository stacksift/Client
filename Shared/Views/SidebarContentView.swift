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
    @EnvironmentObject var filterModel: FilterListViewModel
    @EnvironmentObject var pathModel: PathViewModel
    @State var activeEntry: PathEntry?
    @State private var showingAlert = false
    
    @Binding var editingFilter: Filter

    init(editingFilter: Binding<Filter>) {
        self._editingFilter = editingFilter
    }

    private var filters: [Filter] {
        return filterModel.filters
    }

    private var pathEntries: [PathEntry] {
        return pathModel.entries
    }

    private func setPasteboardString(_ value: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()

        pasteBoard.setString(value, forType: .string)
    }

    var body: some View {
        List {
            Section(header: Text("Filters")) {
                ForEach(filters) { filter in
                    SidebarLinkView(rootFilter: filter, activeEntry: $activeEntry)
                        .contextMenu {
                            Button {
                                setPasteboardString(filter.title)
                            } label: {
                                Label("Copy Name", systemImage: "file")
                            }

                            Button {
                                self.filterModel.editingState = .edit(filter)
                            } label: {
                                Label("Edit…", systemImage: "file")
                            }

                            Button {
                                showingAlert = true
                            } label: {
                                Label("Remove…", systemImage: "file")
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text("Delete \(filter.title)"),
                                      message: Text("This action cannot be undone."),
                                      primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                                        self.filterModel.deleteFilter(filter)
                                      }))
                            }
                        }
                }
            }
            Section(header: Text("Path")) {
                ForEach(pathEntries, id: \.id) { entry in
                    SidebarLinkView(entry: entry, activeEntry: $activeEntry)
                        .contextMenu {
                            Button {
                                setPasteboardString(entry.title)
                            } label: {
                                Label("Copy Name", systemImage: "file")
                            }
                        }
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
        SidebarContentView(editingFilter: .constant(Filter.newFilter))
    }
}
#endif
