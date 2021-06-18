import Foundation

public struct Event: Identifiable {
    public var id: String
    public var kind: String
    public var module: String
    public var title: String
    public var subtitle: String
    public var reportId: String
    public var metrics: EventMetrics

    public init(id: String, kind: String, title: String) {
        self.id = id
        self.kind = kind
        self.module = "no module"
        self.title = title
        self.subtitle = "none"
        self.reportId = "report-1"
        self.metrics = EventMetrics()
    }

    public var kindDisplayName: String {
        switch kind {
        case "frame.deepest-interesting":
            return "Deepest Frame"
        case "resource":
            return "Resource"
        case "exception":
            return "Exception"
        case "note.mach_msg_trap":
            return "mach_msg_trap"
        case "note.objc_msgSend":
            return "objc_msgSend"
        default:
            return kind
        }
    }
}

extension Event: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case kind = "type"
        case module
        case title
        case subtitle
        case reportId = "report_id"
        case metrics
    }
}

