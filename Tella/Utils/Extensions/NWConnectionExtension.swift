//
//  NWConnectionExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 23/7/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Network

extension NWConnection {
    var id: ObjectIdentifier {
        return ObjectIdentifier(self)
    }
    
    /// Convenience for naming connection queues
    var idHash: Int { ObjectIdentifier(self).hashValue }

}
