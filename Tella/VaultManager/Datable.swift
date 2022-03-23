//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit

protocol Datable {
    var data: Data? { get }
}

extension Datable {
    
    init?(data: Data?) {
        return nil
    }
}

extension String: Datable {
    
    var data: Data? {
        return data(using: .utf8)
    }
    
    init?(data: Data?) {
        guard let data = data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        self = string
    }

}

extension UIImage: Datable {
    
    var data: Data? {
        return pngData()
    }
    
}
