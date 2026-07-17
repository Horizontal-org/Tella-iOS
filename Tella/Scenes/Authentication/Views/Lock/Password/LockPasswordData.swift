//
//  LockViewData.swift
//  Tella
//
//   
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

protocol LockViewProtocol {
    var title : String { get }
    var description : String { get }
    var image : String { get }
    var alignement : TextAlignment { get }
    var action : (() -> Void)? { get set }
}

struct LockPasswordData  : LockViewProtocol {
    var title = LocalizableLock.lockPasswordSetSubhead.localized
    var description = LocalizableLock.lockPasswordSetExpl1.localized.bulleted().addline
    + LocalizableLock.lockPasswordSetExpl2.localized.bulleted().addline
    + LocalizableLock.lockPasswordSetExpl3.localized.bulleted()
    var image = "lock.password.B"
    var alignement: TextAlignment = .leading
    var action: (() -> Void)?
}

struct LockConfirmPasswordData  : LockViewProtocol  {
    var title = LocalizableLock.lockPasswordConfirmSubhead.localized
    var description = LocalizableLock.lockPasswordConfirmExpl.localized
    var image = "lock.password.B"
    var alignement: TextAlignment = .center
    var action: (() -> Void)?
}
