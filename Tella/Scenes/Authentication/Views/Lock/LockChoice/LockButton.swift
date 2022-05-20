//
//  LockButton.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

protocol LockButtonProtocol {
    var title : String { get }
    var description: String { get }
    var imageName: String { get }
}

struct PasswordLockButton : LockButtonProtocol {
    var title = Localizable.Lock.lockSelectActionPassword
    var description = Localizable.Lock.lockSelectActionExplPassword
    var imageName = "lock.password"
}

struct PINLockButton : LockButtonProtocol {
    var title = Localizable.Lock.lockSelectActionPin
    var description = Localizable.Lock.lockSelectActionExplPin
    var imageName = "lock.pin"
    
}
