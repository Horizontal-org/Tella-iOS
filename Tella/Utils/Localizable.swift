//
//  Localizable.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import Foundation

struct Localizable {
    
}

extension String {
    
    var bundle: Bundle {
        return Bundle.main
    }
    
    var localized: String {
        return bundle.localizedString(forKey: self, value: nil, table: "Localizable")
    }
}
