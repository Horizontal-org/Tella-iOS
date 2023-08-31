//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

protocol AuthenticationManagerProtocol {
    func keysInitialized() -> Bool
    func login(password:String?) -> Bool
    func initKeys(_ type: PasswordTypeEnum, password:String)
    func updateKeys(_ type: PasswordTypeEnum, newPassword:String, oldPassword:String)
    func getPasswordType() -> PasswordTypeEnum?
}

///   MainAppModel extension contains the methods used for authentication

extension MainAppModel : AuthenticationManagerProtocol {
    
    func keysInitialized() -> Bool {
        return vaultManager.keysInitialized()
    }
    
    func login(password:String?) -> Bool {
        return vaultManager.login(password: password)
    }
    
    func initKeys(_ type: PasswordTypeEnum, password:String)  {
        vaultManager.initKeys(type, password: password)
    }
    
    func updateKeys(_ type: PasswordTypeEnum, newPassword:String, oldPassword:String)  {
        vaultManager.updateKeys(type, newPassword:newPassword, oldPassword: oldPassword)
    }
    
    func getPasswordType() -> PasswordTypeEnum? {
        return vaultManager.getPasswordType()
    }
}
