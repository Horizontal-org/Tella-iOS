//
//  LockButton.swift
//  Tella
//
//   
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

protocol LockButtonProtocol {
    var title : String { get }
    var description: String { get }
    var imageName: String { get }
}

struct PasswordLockButton : LockButtonProtocol {
    var title = LocalizableLock.lockSelectActionPassword.localized
    var description = LocalizableLock.lockSelectActionExplPassword.localized
    var imageName = "lock.password"
}

struct PINLockButton : LockButtonProtocol {
    var title = LocalizableLock.lockSelectActionPin.localized
    var description = LocalizableLock.lockSelectActionExplPin.localized
    var imageName = "lock.pin"
    
}
