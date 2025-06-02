//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
