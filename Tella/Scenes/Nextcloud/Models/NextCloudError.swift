//
//  NextCloudError.swift
//  Tella
//
//  Created by RIMA on 6/8/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct NextCloudError: Error {
    
    let code: Int
    
    init(_ code: Int) {
        self.code = code
    }
    
    var message: String { //TODO: the strings should be changed to Localizable
        switch code {
        case 405:
            return "Folder already exist"
        case 997, 429:
            return "Unauthorised"
        case -1003:
            return "A server with the specified hostname could not be found."
        default:
            return "Folder already exist"
        }
       
    }
}
