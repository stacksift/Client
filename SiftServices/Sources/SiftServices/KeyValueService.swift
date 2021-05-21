import Foundation

public protocol KeyValueService: AnyObject {
    func get<C: Codable>(key: String, type: C.Type) -> C?
    func set<C: Codable>(key: String, type: C.Type)
}
