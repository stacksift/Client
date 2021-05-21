import Foundation

public struct Event: Identifiable {
    public var id: String
    public var kind: Kind
    public var module: String
    public var title: String
    public var subtitle: String
    public var reportId: String
    public var metrics: EventMetrics

    public init(id: String, kind: Event.Kind, title: String) {
        self.id = id
        self.kind = kind
        self.module = "no module"
        self.title = title
        self.subtitle = "none"
        self.reportId = "report-1"
        self.metrics = EventMetrics()
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

extension Event {
    public enum Kind: String {
        case deepestFrame = "frame.deepest-interesting"
        case resource
        case exception
        case machMsgTrap = "note.mach_msg_trap"
        case objcMsgSend = "note.objc_msgSend"
        case unset = ""

        public static let all = Set<Kind>([.deepestFrame, .resource, .exception])

        public var displayName: String {
            switch self {
            case .deepestFrame:
                return "Deepest Frame"
            case .resource:
                return "Resource"
            case .exception:
                return "Exception"
            case .machMsgTrap:
                return "mach_msg_trap"
            case .objcMsgSend:
                return "objc_msgSend"
            case .unset:
                return "Unknown"
            }
        }
    }
}

extension Event.Kind: Codable {
}
