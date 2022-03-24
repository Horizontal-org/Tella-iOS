//
//  Localizable.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

protocol LocalizableDelegate {
    var rawValue : String  { get }
    var tableName: String? { get }
    var localized: String  { get }
}

// MARK: - Default values of the Localizable protocol properties
extension LocalizableDelegate {
    
    var tableName: String? {
        return nil
    }
    
    var bundle: Bundle {
        return Bundle.main
    }
    
    var localized: String {
        return bundle.localizedString(forKey: rawValue, value: nil, table: tableName)
    }
}
