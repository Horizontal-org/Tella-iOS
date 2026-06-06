//
//  SecKeyOptions.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 4/6/2026.
//  Copyright © 2026 HORIZONTAL. All rights reserved.
//

import Foundation
import Security

enum SecKeyOptions {

    static var privateKey: [String: Any] {
        [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 256
        ]
    }

    static var publicKey: [String: Any] {
        [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits as String: 256
        ]
    }

    static var secureEnclavePrivateKey: [String: Any] {
        [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave
        ]
    }

    static var privateKeyCreation: [String: Any] {
        [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
    }
}
