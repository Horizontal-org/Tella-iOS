//
//  LoginManager.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 22/3/2022.
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

protocol AuthenticationManagerProtocol {
    
    func keysInitialized() -> Bool
    func initKeys(_ type: PasswordTypeEnum, password:String) throws
    func updateKeys(_ privateKey: SecKey, _ type: PasswordTypeEnum, newPassword:String, oldPassword:String) throws
    func getPasswordType() -> PasswordTypeEnum
}


class AuthenticationManager:AuthenticationManagerProtocol {

    func keysInitialized() -> Bool {
        return CryptoManager.shared.keysInitialized()
    }
    
    func initKeys(_ type: PasswordTypeEnum, password:String) throws {
        try CryptoManager.shared.initKeys(type, password: password)
        _ = CryptoManager.shared.recoverKey(.PRIVATE, password: password)
    }
    
    func updateKeys(_ privateKey: SecKey, _ type: PasswordTypeEnum, newPassword:String, oldPassword:String) throws {
        
        guard let privateKey = CryptoManager.shared.recoverKey(.PRIVATE, password: oldPassword) else { return }
        
        try CryptoManager.shared.updateKeys(privateKey, type, newPassword:newPassword, oldPassword: oldPassword)
    }
    
    func getPasswordType() -> PasswordTypeEnum {
        return CryptoManager.shared.passwordType
    }
}
