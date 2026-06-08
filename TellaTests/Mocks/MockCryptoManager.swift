//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import XCTest
@testable import Tella

class MockCryptoManager: CryptoManagerInterface, VaultLockManaging {

    var passwordType: PasswordTypeEnum = .tellaPassword

    func unlockAndMigrateIfNeeded(password: String?) async -> Bool {
        true
    }

    func keysInitialized() -> Bool {
        true
    }

    func initKeys(_ type: PasswordTypeEnum, password: String) throws {}

    func updateKeys(
        _ type: PasswordTypeEnum,
        newPassword: String,
        oldPassword: String
    ) throws {}

    func lock() {}

    func withVaultDerivedSQLCipherKey<T>(_ body: (String) throws -> T) throws -> T {
        try body("")
    }

    func encryptUserData(_ data: Data) -> Data? {
        return data
    }
    
    func encrypt(_ data: Data) -> Data? {
        return data
    }
    
    func decrypt(_ data: Data) -> Data? {
        return data
    }

    func encryptFile(at inputFileURL: URL, outputTo outputFileURL: URL) -> Bool {
        true
    }

    func decryptFile(at inputFileURL: URL, outputTo outputFileURL: URL) -> Bool {
        true
    }
    
    func encrypt(_ data: Data, _ publicKey: SecKey) -> Data? {
        return data
    }
    
    func decrypt(_ data: Data, _ privateKey: SecKey) -> Data? {
        return data
    }

}
