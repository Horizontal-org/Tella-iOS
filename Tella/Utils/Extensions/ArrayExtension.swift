//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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

extension Array {
    // Chunk Array into subarrays of fixed size
    func chunked(into size: Int) -> [[Element]] {
        var result: [[Element]] = []
        var index = 0
        while index < count {
            let chunk = Array(self[index..<Swift.min(index + size, count)])
            result.append(chunk)
            index += size
        }
        return result
    }
}
