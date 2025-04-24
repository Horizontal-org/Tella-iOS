//
//  EntityStatus.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 19/3/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum EntityStatus:Int, Codable {
    
    case unknown = 0
    case draft = 1
    case finalized = 2
    case submitted = 3
    case submissionError = 4
    case submissionPending = 7 // no connection on sending, or offline mode - form saved
    case submissionInProgress = 10
    
    func isFinal() -> Bool {
        return !(self == .unknown || self == .draft)
    }
}
