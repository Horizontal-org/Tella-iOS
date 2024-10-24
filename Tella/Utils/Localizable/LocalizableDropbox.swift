//
//  LocalizableDropbox.swift
//  Tella
//
//  Created by gus valbuena on 9/17/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

enum LocalizableDropbox : String, LocalizableDelegate {
    case dropboxAppBar = "Dropbox_AppBar"
    
    case connectionExpiredTitle = "Dropbox_ConnectionExpired_SheetTitle"
    case connectionExpiredExpl = "Dropbox_ConnectionExpired_SheetExpl"
    case connectionExpiredContinue = "Dropbox_ConnectionExpired_Continue_SheetAction"
    case connectionExpiredLogin = "Dropbox_ConnectionExpired_Login_SheetAction"
    
}
