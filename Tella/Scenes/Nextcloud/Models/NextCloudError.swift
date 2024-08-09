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
            return "The username or password is incorrect"
        case -1003:
            return "A server with the specified hostname could not be found."
        case -1009:
            return "No Internet connection. Try again when you are connected to the Internet."
        default:
            return "Unexpected Error occured"
        }
       
    }
}
