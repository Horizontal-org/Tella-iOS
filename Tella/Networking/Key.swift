//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


public protocol KeyType: Hashable {
    var apiString: String { get }
}

public extension KeyType where Self: RawRepresentable, RawValue == String {
    var apiString: String { rawValue }
}

public extension KeyType {
    var apiString: String { String(describing: self) }
}
