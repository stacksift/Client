import SwiftUI
import SiftServices
import ServiceImplemenations
import Models
import MockServiceImplemenations
import Sparkle

extension Services {
    init() {
        let loader = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let service = AuthenticatedNeworkService(loader: loader)
        
        self.init(networkService: service)
    }
}

struct ServicesKey: EnvironmentKey {
    static var defaultValue = Services()
//    static var defaultValue = mockDefaults

    static var mockDefaults: Services {
        let netService = MockNetworkService()

        let event1 = Event(id: "event-1", kind: "frame.deepest-interesting", title: "Event 1")

        netService.addMockResponse("https://api.stacksift.io/v1/events", encodable: [event1])

        let report1 = Report(id: "report-1")

        netService.addMockResponse("https://api.stacksift.io/v1/reports/report-1", encodable: report1)

        let event2 = Event(id: "event-2", kind: "frame.deepest-interesting", title: "Event 2")

        netService.addMockResponse("https://api.stacksift.io/v1/events", encodable: [event2])

        return Services(networkService: netService)
    }
}

extension EnvironmentValues {
    var services: Services {
        get { self[ServicesKey.self] }
    }
}

@main
struct ClientApp: App {
    @State var pathModel = PathViewModel()
    private var updateController: SPUStandardUpdaterController

    init() {
        self.updateController = SPUStandardUpdaterController(updaterDelegate: nil, userDriverDelegate: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pathModel)
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: CommandGroupPlacement.appSettings) {
                Button("Check for Update…") {
                    self.updateController.checkForUpdates(self)
                }
            }
            CommandGroup(after: CommandGroupPlacement.sidebar) {
                Divider()
                Button("Reload") {
                    NotificationCenter.default.post(name: .RefreshData, object: nil)
                }
                .keyboardShortcut("r")
                Divider()
            }
        }
    }
}
