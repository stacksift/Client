public enum PathEntry {
    case report(String)
    case filter(Filter)

    public var title: String {
        switch self {
        case .report(let id):
            return id
        case .filter(let filter):
            return filter.title
        }
    }
}

extension PathEntry: Identifiable {
    public var id: String {
        switch self {
        case .report(let reportId):
            return reportId
        case .filter(let filter):
            return filter.id
        }
    }
}

extension PathEntry: Hashable {
}
