//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

extension Data {
    
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
    
    func string() -> String {
        return String(decoding:  self , as: UTF8.self)
    }
    
    mutating func extract(size: Int?) -> Data? {
        
        guard let size,  self.count > size  else {
            return nil
        }
        
        // Define the length of data to return
        // Create a range based on the length of data to return
        let range = (0..<size)
        
        // Get a new copy of data
        // let subData = self.subdata(in: range)
        
        // Mutate data
        self.removeSubrange(range)
        
        // Return the new copy of data
        return self
    }
    
    func fileExtension(vaultManager:VaultManager) -> String? {
        let fileTypeHelper = FileTypeHelper(data: self).getFileInformation()
        return fileTypeHelper?.fileExtension
    }
    
}
