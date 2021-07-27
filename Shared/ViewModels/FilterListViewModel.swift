import Models
import SiftServices
import Combine
import Foundation

public class FilterListViewModel: ObservableObject {
    public enum EditingState: Hashable {
        case idle
        case newFilter
        case edit(Filter)
    }

    @Published public private(set) var filters: [Filter] {
        didSet {
            let dictionaries = filters.compactMap({ $0.toDictionary() })

            UserDefaults.standard.set(dictionaries, forKey: "Filters")
        }
    }
    @Published public var editingState: EditingState

    public init() {
        self.filters = []
        self.editingState = .idle
    }

    public func reload() {
        guard let value = UserDefaults.standard.array(forKey: "Filters") as? [[String: Any]] else {
            return
        }

        self.filters = value.compactMap({ Filter.fromDictionary($0) })
    }

    public var editingFilter: Filter {
        switch editingState {
        case .idle:
            fatalError()
        case .edit(let filter):
            return filter
        case .newFilter:
            return Filter(title: "New Filter", timeWindow: .lastYear)
        }
    }

    public func saveEditedFilter(_ filter: Filter) {
        switch editingState {
        case .idle:
            fatalError()
        case .edit(let oldFilter):
            let idx = filters.firstIndex(of: oldFilter)!
            filters[idx] = filter
        case .newFilter:
            filters.append(filter)
        }
    }

    public func deleteFilter(_ filter: Filter) {
        filters.removeAll(where: { $0 == filter })
    }
}
