//
//  LockPinData.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

struct LockPinData  : LockViewProtocol {
    var title = LocalizableLock.lockPinSetSubhead.localized
    var description = LocalizableLock.lockPinSetExpl.localized
    var image = "lock.password.B"
    var alignement: TextAlignment = .leading
    var action: (() -> Void)?
}

struct LockConfirmPinData  : LockViewProtocol {
    var title = LocalizableLock.lockPinConfirmSubhead.localized
    var description = LocalizableLock.lockPinConfirmExpl.localized
    var image = "lock.password.B"
    var alignement: TextAlignment = .center
    var action: (() -> Void)?
}

