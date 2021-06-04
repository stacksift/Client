import SwiftUI
import SiftServices
import ServiceImplemenations
import Models
import OAuth
import MockServiceImplemenations
import Sparkle

extension Services {
    init() {
        let config = BasicOauthConfiguration(clientId: "4m6dp6bu89snr7s0prhp7dkj78",
                                             clientPassword: "1m2a0q4s7t8q0ivoucoljldfthci6psc1f022621bao4lctmon7a",
                                             scopes: ["openid", "profile"],
                                             keychainItemName: "io.stacksift.token")
        self.init(networkService: AuthenticatedNeworkService(configuration: config))
    }
}

struct ServicesKey: EnvironmentKey {
    static var defaultValue = Services()
//    static var defaultValue = mockDefaults

    static var mockDefaults: Services {
        let netService = MockNetworkService()

        let event1 = Event(id: "event-1", kind: .deepestFrame, title: "Event 1")

        netService.addMockResponse("https://api.stacksift.io/v1/events", encodable: [event1])

        let report1 = Report(id: "report-1")

        netService.addMockResponse("https://api.stacksift.io/v1/reports/report-1", encodable: report1)

        let event2 = Event(id: "event-2", kind: .deepestFrame, title: "Event 2")

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

    init() {
        let _ = SUUpdater.shared()
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
                    SUUpdater.shared().checkForUpdates(self)
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
