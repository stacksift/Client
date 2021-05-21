import Models
import SiftServices
import Combine

class PathViewModel: ObservableObject {
    @Published public private(set) var entries: [PathEntry]
    @Published public var rootFilter: Filter?

    init() {
        self.entries = []
        self.rootFilter = nil
    }

    var rootFilterEntry: PathEntry? {
        return rootFilter.flatMap({ .filter($0) })
    }

    func addEntry(_ entry: PathEntry) {
        entries.append(entry)
    }

    func removeAllEntries() {
        entries = []
    }
}
