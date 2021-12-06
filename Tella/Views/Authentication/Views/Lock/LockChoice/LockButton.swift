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
    var title = LocalizableLock.passwordButtonTitle.localized
    var description = LocalizableLock.passwordButtonDescription.localized
    var imageName = "lock.password"
}

struct PINLockButton : LockButtonProtocol {
    var title = LocalizableLock.pinButtonTitle.localized
    var description = LocalizableLock.pinButtonDescription.localized
    var imageName = "lock.pin"
    
}
