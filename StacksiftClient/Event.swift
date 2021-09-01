import Foundation

public struct Event: Identifiable {
    public var id: String
    public var kind: String
    public var module: String
    public var title: String
    public var subtitle: String
    public var reportId: String
    public var metrics: EventMetrics

    public enum Group {
        case frame
        case exception
        case note
        case watchdog
        case memory

        var name: String {
            switch self {
            case .frame:
                return "frame"
            case .exception:
                return "exception"
            case .note:
                return "note"
            case .watchdog:
                return "watchdog"
            case .memory:
                return "memory"
            }
        }
    }

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
        case "note.objc-life-cycle":
            return "Obj-C Life Cycle"
        case "note.8badf00d":
            return "Watchdog Termination"
        default:
            return kind
        }
    }

    public var group: Group {
        switch kind {
        case "frame.deepest-interesting":
            return .frame
        case "exception":
            return .exception
        case "note.8badf00d":
            return .watchdog
        case "note.allocator":
            return .memory
        default:
            return .note
        }
    }

    public var kindDisplayDescription: String {
        switch kind {
        case "frame.deepest-interesting":
            return "The deepest frame in the stack that cannot be ignored with high confidence. This grouping relies heavily on heuristics. Many crash reporting services use an implemenation of this method for grouping crashes."
        case "exception":
            return "A runtime exception that resulted in process termination. Can be either from C++ or Objective-C."
        case "note.mach_msg_trap":
            return "This report includes a blamed thread that was parked in the mach_msg_trap function. This typically indicates that the thread did not crash, but when the OS terminated the process, it was not able to attribute the event to one single thread."
        case "note.objc_msgSend":
            return "A thread crashing in objc_msgSend typically indicates that the pointer being send a message wasn't a valid object."
        case "note.objc-life-cycle":
            return "A thread crashed while performing Objective-C object runtime life cycle management. This typically indicates a memory corruption issue, often as simple as an over-release."
        case "note.8badf00d":
            return "Indicates that the main thread was blocked for an excessive amount of time. Take care when interpreting the main thread's stack trace, as it represents just the moment in time when the OS decided to terminate the process."
        default:
            return "A full description for \"\(kind)\" is forthcoming."
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

extension Event: Hashable {
}
