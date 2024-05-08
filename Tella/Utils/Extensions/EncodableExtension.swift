//
//  EncodableExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 8/5/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation


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
