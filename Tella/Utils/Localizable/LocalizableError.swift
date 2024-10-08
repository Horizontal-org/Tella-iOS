//
//  LocalizableError.swift
//  Tella
//
//  Created by gus valbuena on 8/23/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

enum LocalizableError : String, LocalizableDelegate {
    case invalidUrl = "Error_InvalidURL_Expl"
    case unexpectedResponse = "Error_Unexpected_Response_Expl"
    case unauthorized = "Error_Unauthorized_Expl"
    case forbidden = "Error_Forbidden_Expl"
    case commonError = "Common_Error"
    case noInternet = "Error_NoInternetConnection"
    
    case gDriveUnauthorized = "Error_GDrive_Unauthorized_Expl"
    case gDriveForbidden = "Error_GDrive_Forbidden_Expl"
    
    case ncFolderExist = "Error_Nextcloud_ForderExist"
    case ncInvalidCredentials = "Error_Nextcloud_InvalidCredentials"
    case ncTooManyRequests = "Error_Nextcloud_ManyFailedRequests"
}
