import SiftServices

public extension Services {
    static var mock: Services {
        let mockNetworkService = URLKeyedMockNetworkService()

        mockNetworkService.addMockResponse("https://api.stacksift.io/v1/events?platform=macOS", json: """
[{"id":"event-1", "type":"exception"}]
""")
        mockNetworkService.addMockResponse("https://api.stacksift.io/v1/reports/event-1", data: "Report Body Text".data(using: .utf8)!)

        return Services(networkService: mockNetworkService)
    }
}
