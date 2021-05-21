import SiftNetwork

public struct Services {
    public var networkService: NetworkService

    public init(networkService: NetworkService) {
        self.networkService = networkService
    }
}
