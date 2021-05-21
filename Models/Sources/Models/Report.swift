import Foundation

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

public struct StackTraceFrame: Codable {
    public var address: Int
    public var symbol: String?
    public var offset: Int
    public var file: String?
    public var line: Int?
    public var module: String
}

public struct StackTrace: Codable {
    public var crashed: Bool
    public var frames: [StackTraceFrame]
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

    public init(id: String) {
        self.id = id
        self.platform = "macOS"
        self.osVersion = VersionPair(build: "123", version: "1.0")
        self.hostExecutable = "com.mycompany.PhonyApp"
        self.hostVersion = VersionPair(build: "1", version: "2.0")
        self.dateMillis = Int(Date().timeIntervalSince1970 * 1000.0)
        self.binaryImages = []
        self.traces = []
        self.eventIds = []
        self.relationships = []
    }

    public var date: Date {
        return Date(timeIntervalSince1970: Double(dateMillis/1000))
    }

    public var crashedThreadIndex: Int? {
        return traces.firstIndex(where: { $0.crashed })
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
    }
}

extension Report {
    public func renderReportCrash() throws -> String {
        guard let firstImage = binaryImages.first else {
            throw NSError(domain: "blah", code: 1)
        }

        let pid = 0

        var output = ""

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

        output += "Exception Type:\n"
        output += "Exception Codes:\n"
        output += "Exception Note:\n\n"

        output += "Termination Signal:\n"
        output += "Termination Reason:\n"
        output += "Terminating Process:\n\n"

        output += "Application Specific Information:\n\n"

        for i in 0..<traces.count {
            let trace = traces[i]
            let state = trace.crashed ? " Crashed" : ""

            output += "\nThread \(i)\(state):\n"

            for j in 0..<trace.frames.count {
                let frame = trace.frames[j]
                let frameIdx = String(format: "%-3d", j)
                let module = frame.module.padding(toLength: 32, withPad: " ", startingAt: 0)
                let addr = String(format: "0x%016x", frame.address)
                let symbol = frame.symbol ?? ""
                let file = frame.file ?? ""
                let line = frame.line.flatMap({ String($0) }) ?? ""
                let offset = frame.offset
                let location = file == "" ? "" : " \(file):\(line)"

                output += "\(frameIdx) \(module) \(addr) \(symbol) + \(offset)\(location)\n"
            }
        }

        // this is totally bogus...
        output += "\nThread \(threadIndex) crashed with x86 Thread State (64-bit):\n\n"

        output += "Binary Images:\n"

        for image in binaryImages {
            let start = String(format: "0x%x", image.loadAddress).padding(toLength: 18, withPad: " ", startingAt: 0)
            let end = String(format: "0x%x", image.endAddress).padding(toLength: 18, withPad: " ", startingAt: 0)
            let baseComponent = image.lastPathComponent

            output += "\(start) - \(end) \(baseComponent) () <\(image.formattedIdentifier)> \(image.path)\n"
        }

        return output
    }
}
