//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


public protocol Value {
    var apiString: String { get }
}

extension Int: Value {}
extension String: Value {}
extension Bool: Value {}
extension Array: Value {}

extension Value {
    public var apiString: String { String(describing: self) }
}
