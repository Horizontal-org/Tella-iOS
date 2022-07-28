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
    var title = Localizable.Lock.passwordButtonTitle
    var description = Localizable.Lock.passwordButtonDescription
    var imageName = "lock.password"
}

struct PINLockButton : LockButtonProtocol {
    var title = Localizable.Lock.pinButtonTitle
    var description = Localizable.Lock.pinButtonDescription
    var imageName = "lock.pin"
    
}
