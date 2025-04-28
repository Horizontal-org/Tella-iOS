//
//  ConfigurationManager.swift
//  Tella
//
//  Created by gus valbuena on 9/16/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct ConfigurationManager {
    static func getValue(_ key: String) -> String? {
        guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else { return nil }
        guard let configValue: String = infoDictionary[key] as? String else { return nil }
        
        return configValue
    }
}
