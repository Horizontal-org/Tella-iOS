//
//  NextcloudUploadProgressInfo.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 31/7/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class NextcloudUploadProgressInfo : UploadProgressInfo {
    var chunkFiles : [(fileName: String, size: Int64)] = []
    var chunkFileSent : (fileName: String, size: Int64)?
    var step : NextcloudUploadStep = .initial
}

enum NextcloudUploadStep {
    case initial
    case start
    case chunkSent
    case progress
    case finished
}

