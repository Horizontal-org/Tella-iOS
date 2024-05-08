//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
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

extension Encodable {
    
    var jsonString: String? {
        if let jsonData = try? JSONEncoder().encode(self), let json = String(bytes: jsonData, encoding: .utf8) {
            return json
        } else {
            return nil
        }
    }
    
    var dictionary: [String: Any] {
        do {
            
            let data = try JSONEncoder().encode(self)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                return [:]
            }
            return dictionary
        } catch let error as NSError {
            debugLog(error)
            return [:]
        }
    }
    var arraydDictionnary: [[String: Any]] {
        do {
            
            let data = try JSONEncoder().encode(self)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else {
                return [[:]]
            }
            return dictionary
        } catch let error as NSError {
            debugLog(error)
            return [[:]]
        }
    }

}

extension String {
    var dictionnary: [String:Any] {
        
        guard let data = self.data(using: .utf8) else { return [:]}
        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any> else { return [:]}
            return jsonArray
        } catch let error as NSError {
            debugLog(error)
            return [:]
        }
    }
    
    var arraydDictionnary: [[String:Any]] {
        
        guard let data = self.data(using: .utf8) else { return [[:]]}
        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] else { return[ [:]]}
            return jsonArray
        } catch let error as NSError {
            debugLog(error)
            return [[:]]
        }
    }

    
    func decode<T: Codable>(_ type: T.Type) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: self)
        return try JSONDecoder().decode (type, from: data)
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
