//
//  SecKeyExtension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 15/4/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Security
import Foundation

extension SecKey {
    func getString() -> String? {
        guard let data = getData() else {
            return nil
        }
        return data.base64EncodedString()
    }
    
    func getData() -> Data? {
        var error:Unmanaged<CFError>?
        guard let cfdata = SecKeyCopyExternalRepresentation(self, &error) else {
            return nil
        }
        let data:Data = cfdata as Data
        return data
    }
    
    func getPublicKey() -> SecKey? {
        return SecKeyCopyPublicKey(self)
    }
}

