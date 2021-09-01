import Foundation
import Cocoa

public struct BinaryImage {
    public var path: String
    public var loadAddress: Int
    public var size: Int
    public var id: String

    public var lastPathComponent: String {
        return path.components(separatedBy: "/").last ?? ""
    }

    public var endAddress: Int {
        return loadAddress + size
    }

    public var formattedIdentifier: String {
        var upperId = id.uppercased()

        guard upperId.utf16.count == 32 else {
            return id.uppercased()
        }

        upperId.insert("-", at: upperId.index(upperId.startIndex, offsetBy: 20))
        upperId.insert("-", at: upperId.index(upperId.startIndex, offsetBy: 16))
        upperId.insert("-", at: upperId.index(upperId.startIndex, offsetBy: 12))
        upperId.insert("-", at: upperId.index(upperId.startIndex, offsetBy: 8))

        return upperId
    }

    public func contains(address: Int) -> Bool {
        return loadAddress <= address && address < endAddress
    }
}

extension BinaryImage: Identifiable {
}

extension BinaryImage: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "identifier"
        case loadAddress = "load_address"
        case size
        case path
    }
}

public struct VersionPair: Codable {
    public var build: String
    public var version: String

    public var string: String {
        return "\(version) (\(build))"
    }
}

public struct StackTraceFrame {
    public var address: Int
    public var symbol: String?
    public var offset: Int
    public var file: String?
    public var line: Int?
    public var module: String
    public var symbolicationError: String?

    public init(symbol: String, file: String? = nil, line: Int? = nil, module: String) {
        self.address = 0
        self.symbol = symbol
        self.offset = 0
        self.file = file
        self.line = line
        self.module = module
    }

    public var fileBasename: String? {
        return file.map { URL(fileURLWithPath: $0) }?.lastPathComponent
    }

    public var location: String? {
        guard let base = fileBasename else {
            return nil
        }

        guard  let line = line else {
            return base
        }

        return "\(base):\(line)"
    }

    public var hasSymbol: Bool {
        return symbol?.isEmpty == false
    }
}

extension StackTraceFrame: Codable {
    enum CodingKeys: String, CodingKey {
        case address
        case symbol
        case offset
        case file
        case line
        case module
        case symbolicationError = "symbolication_error"
    }
}

public struct StackTrace: Codable {
    public var crashed: Bool
    public var frames: [StackTraceFrame]

    public init(crashed: Bool = false, frames: [StackTraceFrame]) {
        self.crashed = crashed
        self.frames = frames
    }
}

public struct Signal: Codable {
    public var number: Int

    public var name: String {
        switch number {
        case 4:
            return "SIGILL"
        case 5:
            return "SIGTRAP"
        case 6:
            return "SIGABRT"
        case 9:
            return "SIGKILL"
        case 10:
            return "SIGBUS"
        case 11:
            return "SIGSEGV"
        default:
            return "SIGUNKNOWN"
        }
    }

    public var displayName: String? {
        switch number {
        case 5:
            return "Trace/BPT trap: 5"
        default:
            return nil
        }
    }
}

public struct MachException: Codable {
    public var number: Int
    public var code: Int

    public var name: String {
        switch number {
        case 1:
            return "EXC_BAD_ACCESS"
        case 2:
            return "EXC_BAD_INSTRUCTION"
        case 3:
            return "EXC_ARITHMETIC"
        case 5:
            return "EXC_SOFTWARE"
        case 6:
            return "EXC_BREAKPOINT"
        case 10:
            return "EXC_CRASH"
        case 11:
            return "EXC_RESOURCE"
        case 12:
            return "EXC_GUARD"
        case 13:
            return "EXC_CORPSE_NOTIFY"
        default:
            return "UNKNOWN"
        }
    }

    public var equivalentSignal: Signal? {
        // this is a little tricky, as the equivalent signal is
        // architecture-dependant.

        switch number {
        case 1:
            return Signal(number: 11)
        case 2:
            return Signal(number: 5)
        case 6:
            return Signal(number: 6)
        case 10:
            return Signal(number: 9)
        default:
            return nil
        }
    }
}

public struct Report {
    public var id: String
    public var platform: String
    public var osVersion: VersionPair
    public var hostExecutable: String
    public var hostVersion: VersionPair
    public var dateMillis: Int
    public var binaryImages: [BinaryImage]
    public var traces: [StackTrace]
    public var eventIds: [String]
    public var relationships: [Event]
    public var type: String
    public var machException: MachException?
    public var signal: Signal?
    public var terminationReason: String?
    public var architecture: String?

    public init(id: String, traces: [StackTrace] = [], relationships: [Event] = []) {
        self.id = id
        self.platform = "macOS"
        self.osVersion = VersionPair(build: "123", version: "1.0")
        self.hostExecutable = "com.mycompany.PhonyApp"
        self.hostVersion = VersionPair(build: "1", version: "2.0")
        self.dateMillis = Int(Date().timeIntervalSince1970 * 1000.0)
        self.binaryImages = []
        self.traces = traces
        self.eventIds = []
        self.relationships = relationships
        self.type = "mach_exception"
    }

    public var date: Date {
        return Date(timeIntervalSince1970: Double(dateMillis/1000))
    }

    public var crashedThreadIndex: Int? {
        return traces.firstIndex(where: { $0.crashed })
    }

    public var blamedTrace: StackTrace? {
        return traces.first(where: { $0.crashed }) ?? traces.first
    }

    public func events(for frame: StackTraceFrame) -> [Event] {
        return relationships
            .filter({ $0.kind.starts(with: "frame") })
            .filter({ $0.title == frame.symbol })
    }

    public func events(for trace: StackTrace) -> [Event] {
        return relationships
            .filter({ $0.kind.starts(with: "frame") == false })
    }
}

extension Report: Identifiable {
}

extension Report: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "identifier"
        case platform
        case osVersion = "os_version"
        case hostExecutable = "host_executable"
        case hostVersion = "host_version"
        case dateMillis = "date"
        case binaryImages = "binary_images"
        case traces
        case eventIds = "event_ids"
        case relationships
        case type
        case machException = "mach_exception"
        case signal
        case terminationReason = "termination_reason"
        case architecture
    }
}

extension NSMutableAttributedString {
    static func +=(lhs: inout NSMutableAttributedString, rhs: NSAttributedString) {
        lhs.append(rhs)
    }

    static func +=(lhs: inout NSMutableAttributedString, rhs: String) {
        let font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        let color = NSColor.textColor

        lhs += NSAttributedString(string: rhs, attributes: [.foregroundColor: color, .font: font])
    }
}

extension Report {
    public var machExceptionDisplayType: String {
        let excName = machException?.name
        let excSignal = machException?.equivalentSignal

        switch (excName, excSignal) {
        case (let a?, nil):
            return a
        case (let a?, let b?):
            return "\(a) (\(b.name))"
        default:
            return ""
        }
    }

    private var effectiveSignal: Signal? {
        return signal ?? machException?.equivalentSignal
    }

    private var terminationSignal: String? {
        return effectiveSignal?.displayName
    }

    private var displayTerminationReason: String? {
        if let reason = terminationReason {
            return reason
        }

        if let signal = effectiveSignal {
            let hex = String(format:"%x", signal.number)

            return "Namespace SIGNAL, Code 0x\(hex)"
        }

        return nil
    }

    public func renderReportCrash() throws -> NSAttributedString {
        guard let firstImage = binaryImages.first else {
            throw NSError(domain: "blah", code: 1)
        }

        let pid = 0

        var output = NSMutableAttributedString(string: "")

        output += "Process:               \(firstImage.lastPathComponent) [\(pid)]\n"
        output += "Path:                  \(firstImage.path)\n"
        output += "Identifier:            \(hostExecutable)\n"
        output += "Version:               \(hostVersion.string)\n"
        output += "Code Type:\n"
        output += "Parent Process:        ??? [1]\n"
        output += "Responsible:           \(firstImage.lastPathComponent) [\(pid)]\n"
        output += "User ID:               \(pid)\n\n"

        // 2021-03-24 21:33:35.000 -0400
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"

        let formattedData = formatter.string(from: date)

        output += "Date/Time:             \(formattedData)\n"
        output += "OS Version:            \(platform) \(osVersion.string)\n"
        output += "Report Version:        12\n\n"

        let threadIndex = crashedThreadIndex ?? 0

        output += "Crashed Thread:        \(threadIndex)\n\n"

        output += "Exception Type:        \(machExceptionDisplayType)\n"
        output += "Exception Codes:\n"
        output += "Exception Note:\n\n"

        if let value = terminationSignal {
            output += "Termination Signal:    \(value)\n"
        }

        if let value = displayTerminationReason {
            output += "Termination Reason:    \(value)\n"
        }

        output += "Terminating Process:\n\n"

        output += "Application Specific Information:\n\n"

        let font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)

        let errorAttrs: [NSAttributedString.Key : Any]? = [.foregroundColor: NSColor.red, .font: font]

        var failedAddresses = Set<Int>()

        for i in 0..<traces.count {
            let trace = traces[i]
            let state = trace.crashed ? " Crashed" : ""

            output += "\nThread \(i)\(state):\n"

            for j in 0..<trace.frames.count {
                let frame = trace.frames[j]
                let frameIdx = String(format: "%-3d", j)
                let module = frame.module.padding(toLength: 32, withPad: " ", startingAt: 0)
                let addr = String(format: "0x%l016x", frame.address)

                output += "\(frameIdx) \(module) "

                if frame.symbolicationError != nil {
                    failedAddresses.insert(frame.address)
                }

                output += addr

                if let symbol = frame.symbol, frame.hasSymbol {
                    output += " \(symbol)"
                }

                if frame.offset > 0 {
                    output += " + \(frame.offset)"
                }

                if let location = frame.location {
                    output += " \(location)"
                }

                output += "\n"
            }
        }

        let archName = architecture == "X86_64" ? "x86" : "ARM"
        output += "\nThread \(threadIndex) crashed with \(archName) Thread State (64-bit):\n\n"

        output += "Binary Images:\n"

        for image in binaryImages {
            let start = String(format: "0x%lx", image.loadAddress).padding(toLength: 18, withPad: " ", startingAt: 0)
            let end = String(format: "0x%lx", image.endAddress).padding(toLength: 18, withPad: " ", startingAt: 0)
            let baseComponent = image.lastPathComponent
            let identifier = image.formattedIdentifier

            let failed = failedAddresses.contains(where: { image.contains(address: $0) })

            output += "\(start) - \(end) \(baseComponent) () <"

            if failed {
                output += NSAttributedString(string: identifier, attributes: errorAttrs)
            } else {
                output += identifier
            }

            output += "> \(image.path)\n"
        }

        return output
    }
}

