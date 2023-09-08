//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

struct JSONStringEncoder {
    /**
     Encodes a dictionary into a JSON string.
     - parameter dictionary: Dictionary to use to encode JSON string.
     - returns: A JSON string. `nil`, when encoding failed.
     */
    func encode(_ dictionary: [String: Any]) -> Data? {
        guard JSONSerialization.isValidJSONObject(dictionary) else {
            return nil
        }
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        let jsonData: Data
        
        dictionary.forEach { (arg) in
            jsonObject.setValue(arg.value, forKey: arg.key )
        }
        
        do {
            jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            if let jsonString = String.init(data: jsonData, encoding: String.Encoding.utf8)   {
                debugLog(jsonString )
            }
            return jsonData
        } catch {
            return nil
        }
    }
}
