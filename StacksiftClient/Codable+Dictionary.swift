import Foundation

public extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }

        let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)

        return jsonObj.flatMap { $0 as? [String: Any] }
    }
}

public extension Decodable {
    static func fromDictionary(_ dict: [String: Any]) -> Self? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []) else {
            return nil
        }

        return try? JSONDecoder().decode(Self.self, from: data)
    }
}

