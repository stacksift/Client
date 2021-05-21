import Models
import SiftServices
import Combine

public class FilterListViewModel: ObservableObject {
    @Published public private(set) var filters: [Filter]

    public init() {
        self.filters = []
    }

    public func reload() {
        self.filters = Filter.defaultList
    }
}
