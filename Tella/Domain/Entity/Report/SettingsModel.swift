//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


class SettingsModel: ObservableObject, Codable {
    
    @Published var offLineMode = false
    @Published var quickDelete: Bool = false
    @Published var deleteVault: Bool = false
    @Published var deleteForms: Bool = false
    @Published var deleteServerSettings: Bool = false
    @Published var showRecentFiles: Bool = false
    @Published var lockTimeout: LockTimeoutOption = .immediately
    @Published var screenSecurity: Bool = true
    
    enum CodingKeys: CodingKey {
        case offLineMode
        case quickDelete
        case deleteVault
        case deleteForms
        case deleteServerSettings
        case showRecentFiles
        case lockTimeout
        case screenSecurity
    }
    
    init() {
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offLineMode = try container.decode(Bool.self, forKey: .offLineMode)
        quickDelete = try container.decode(Bool.self, forKey: .quickDelete)
        deleteVault = try container.decode(Bool.self, forKey: .deleteVault)
        deleteForms = try container.decode(Bool.self, forKey: .deleteForms)
        deleteServerSettings = try container.decode(Bool.self, forKey: .deleteServerSettings)
        showRecentFiles = try container.decode(Bool.self, forKey: .showRecentFiles)
        
        let lockTimeoutString = try container.decode(String.self, forKey: .lockTimeout)
        lockTimeout = LockTimeoutOption(rawValue: lockTimeoutString) ?? .immediately
        screenSecurity = try container.decode(Bool.self, forKey: .screenSecurity)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offLineMode, forKey: .offLineMode)
        try container.encode(quickDelete, forKey: .quickDelete)
        try container.encode(deleteVault, forKey: .deleteVault)
        try container.encode(deleteForms, forKey: .deleteForms)
        try container.encode(deleteServerSettings, forKey: .deleteServerSettings)
        try container.encode(showRecentFiles, forKey: .showRecentFiles)
        try container.encode( lockTimeout.rawValue, forKey: .lockTimeout)
        try container.encode(screenSecurity, forKey: .screenSecurity)
    }
}
