//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation


extension Dictionary {
    
    func decode<T: Codable>(_ type: T.Type) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self)
        return try JSONDecoder().decode (type, from: data)
    }
    
    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self)
        return try JSONDecoder().decode (type, from: data)
    }
    
    var jsonString: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }
        return String(data: theJSONData, encoding: .ascii)
    }
    
    var jsonData: Data? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }
        return theJSONData
    }

}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            debugLog(error.localizedDescription)
        }
    }
    return nil
}
