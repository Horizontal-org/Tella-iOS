//
//  Localizable.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
