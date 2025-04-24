//
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import Foundation

protocol KeychainProtocol {

    func load(key: String) -> Data?
    func load(key: String) -> String?
    func load<T: Codable>(key: String) -> T?
    func remove(key: String)

    @discardableResult
    func save(key: String, data: Data) -> OSStatus
    @discardableResult
    func save(key: String, string: String) -> OSStatus
    @discardableResult
    func save<T: Codable>(key: String, object: T) -> OSStatus

}

class KeychainManager: KeychainProtocol {
    
    func load(key: String) -> String? {
        guard let data: Data = load(key: key) else {
            return nil
        }
        return String(decoding: data, as: UTF8.self)
    }
    
    @discardableResult
    func save<T>(key: String, object: T) -> OSStatus where T : Encodable {
        guard let data = try? JSONEncoder().encode(object) else {
            return -1
        }
        return save(key: key, data: data)
    }

    func load<T>(key: String) -> T? where T : Decodable, T : Encodable {
        guard let data: Data = load(key: key) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    @discardableResult
    func save(key: String, string: String) -> OSStatus {
        guard let data = string.data(using: .utf8) else {
            return -1
        }
        return save(key: key, data: data)
    }
    
    @discardableResult
    func save(key: String, data: Data) -> OSStatus {
        let query = [kSecClass as String: kSecClassGenericPassword as String,
                    kSecAttrAccount as String: key,
                    kSecValueData as String: data] as [String : Any]
        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: String) -> Data? {
        let query: [String : Any] = [
             kSecClass as String       : kSecClassGenericPassword,
             kSecAttrAccount as String : key,
             kSecReturnData as String  : kCFBooleanTrue!,
             kSecMatchLimit as String  : kSecMatchLimitOne ]

         var dataTypeRef: AnyObject? = nil
         let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

         if status == noErr {
            if let dataTypeRef = dataTypeRef as? Data{
                return dataTypeRef
            }
         }
        return nil
    }
    
    func remove(key: String) {
        let query:[String : Any] =
            [kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
    }

}
