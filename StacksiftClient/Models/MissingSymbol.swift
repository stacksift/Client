import Foundation

public struct MissingSymbol: Codable {
    var id: String
    var platform: String
    var executable: String
    var version: VersionPair
    var path: String
    var date: Int
}
