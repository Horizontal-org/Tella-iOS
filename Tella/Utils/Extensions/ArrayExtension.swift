//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation

extension Array {
    func rearrange<T>(fromIndex: Int, toIndex: Int) -> Array<T>{
        var array = self
        let element = array.remove(at: fromIndex)
        array.insert(element, at: toIndex)
        
        return array as! Array<T>
    }

    func decode<T: Codable>(_ type: T.Type) throws -> [T] {
        var items : [T] = []
        self.forEach { item in
            
            guard let dictionaryItem = (item as? Dictionary<String,Any>) else {return}
            do {
                try items.append(dictionaryItem.decode(T.self))
            } catch(let error) {
                debugLog(error)
            }
        }
        return items
    }
    
    
}
