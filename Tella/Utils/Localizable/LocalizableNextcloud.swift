//
//  LocalizableNextcloud.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 1/7/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum LocalizableNextcloud : String, LocalizableDelegate {
    case nextcloudAppBar = "Nextcloud_AppBar"

    case connectionExpiredTitle = "Nextcloud_ConnectionExpired_SheetTitle"
    case connectionExpiredExpl = "Nextcloud_ConnectionExpired_SheetExpl"
    case connectionExpiredContinue = "Nextcloud_ConnectionExpired_Continue_SheetAction"
    case connectionExpiredLogin = "Nextcloud_ConnectionExpired_Login_SheetAction"
    case recreateFolderMsg = "Nextcloud_RecreateFolder_Toast"
}
