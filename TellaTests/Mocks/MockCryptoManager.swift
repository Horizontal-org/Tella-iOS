//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import XCTest
@testable import Tella

class MockCryptoManager: CryptoManagerInterface {

    func encryptUserData(_ data: Data) -> Data? {
        return data
    }
    
    func encrypt(_ data: Data) -> Data? {
        return data
    }
    
    func decrypt(_ data: Data) -> Data? {
        return data
    }
    
    func encrypt(_ data: Data, _ publicKey: SecKey) -> Data? {
        return data
    }
    
    func decrypt(_ data: Data, _ privateKey: SecKey) -> Data? {
        return data
    }

}
