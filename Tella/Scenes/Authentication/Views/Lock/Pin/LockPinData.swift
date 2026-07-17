//
//  LockPinData.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

struct LockPinData  : LockViewProtocol {
    var title = LocalizableLock.lockPinSetSubhead.localized
    var description = LocalizableLock.lockPinSetExpl1.localized.bulleted().addline
    + LocalizableLock.lockPinSetExpl2.localized.bulleted()
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

