//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

//// Represents the settings model for the application
class SettingsModel: ObservableObject, Codable {
    
    /// Whether offline mode is enabled
    @Published var offlineMode = false
    
    /// Whether quick delete mode is enabled
    @Published var quickDelete: Bool = false
    
    /// Whether delete files and folders is enabled
    @Published var deleteVault: Bool = false
    
    /// Whether delete connections is enabled
    @Published var deleteServerSettings: Bool = false
    
    /// Whether recent files is enabled
    @Published var showRecentFiles: Bool = false
    
    /// Lock timeout option
    @Published var lockTimeout: LockTimeoutOption = .immediately
    
    /// Delete after fail option
    @Published var deleteAfterFail: DeleteAfterFailOption = .off
    
    /// Show the amount of unlock attempts in the unlock screen
    @Published var showUnlockAttempts: Bool = false
    
    /// Track the amount of unlock attempts
    @Published var unlockAttempts: Int = 0
    
    /// Whether screen security is enabled
    @Published var screenSecurity: Bool = true
    
    /// Whether preserve metadata is enabled
    @Published var preserveMetadata: Bool = false
    
    
    /// Whether feedback sharing is enabled
    @Published var shareFeedback: Bool = false
    
    ///  should Merge Vault Files to database : 
    ///  - on unlock it returns the saved value, if it doesn't exist it returns true,
    ///  - on lock it returns false
    @Published var shouldMergeVaultFilesToDb: Bool? = nil

    enum CodingKeys: CodingKey {
        case offlineMode
        case quickDelete
        case deleteVault
        case deleteServerSettings
        case showRecentFiles
        case lockTimeout
        case deleteAfterFail
        case showUnlockAttempts
        case unlockAttempts
        case screenSecurity
        case preserveMetadata
        case shareFeedback
        case shouldMergeVaultFilesToDb
    }
    
    init() {
        
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        offlineMode = try container.decode(Bool.self, forKey: .offlineMode)
        quickDelete = try container.decode(Bool.self, forKey: .quickDelete)
        deleteVault = try container.decode(Bool.self, forKey: .deleteVault)
        deleteServerSettings = try container.decode(Bool.self, forKey: .deleteServerSettings)
        showRecentFiles = try container.decode(Bool.self, forKey: .showRecentFiles)
        
        let lockTimeoutString = try container.decode(String.self, forKey: .lockTimeout)
        lockTimeout = LockTimeoutOption(rawValue: lockTimeoutString) ?? .immediately
        let deleteAfterFailString = try container.decode(String.self, forKey: .deleteAfterFail)
        deleteAfterFail = DeleteAfterFailOption(rawValue: deleteAfterFailString) ?? .off
        unlockAttempts = try container.decode(Int.self, forKey: .unlockAttempts)
        showUnlockAttempts = try container.decode(Bool.self, forKey: .showUnlockAttempts)
        screenSecurity = try container.decode(Bool.self, forKey: .screenSecurity)
        preserveMetadata = try container.decode(Bool.self, forKey: .preserveMetadata)
        shareFeedback = try container.decode(Bool.self, forKey: .shareFeedback)
        shouldMergeVaultFilesToDb = try container.decode(Bool.self, forKey: .shouldMergeVaultFilesToDb)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(offlineMode, forKey: .offlineMode)
        try container.encode(quickDelete, forKey: .quickDelete)
        try container.encode(deleteVault, forKey: .deleteVault)
        try container.encode(deleteServerSettings, forKey: .deleteServerSettings)
        try container.encode(showRecentFiles, forKey: .showRecentFiles)
        try container.encode( lockTimeout.rawValue, forKey: .lockTimeout)
        try container.encode(deleteAfterFail.rawValue, forKey: .deleteAfterFail)
        try container.encode(unlockAttempts, forKey: .unlockAttempts)
        try container.encode(showUnlockAttempts, forKey: .showUnlockAttempts)
        try container.encode(screenSecurity, forKey: .screenSecurity)
        try container.encode(preserveMetadata, forKey: .preserveMetadata)
        try container.encode(shareFeedback, forKey: .shareFeedback)
        try container.encode(shouldMergeVaultFilesToDb, forKey: .shouldMergeVaultFilesToDb)
    }
}
