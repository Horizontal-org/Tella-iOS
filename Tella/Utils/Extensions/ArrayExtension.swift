//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension Array {
    func rearrange<T>(fromIndex: Int, toIndex: Int) -> Array<T>{
        var array = self
        let element = array.remove(at: fromIndex)
        array.insert(element, at: toIndex)
        
        return array as! Array<T>
    }
}
