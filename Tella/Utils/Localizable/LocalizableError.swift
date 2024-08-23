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
}
