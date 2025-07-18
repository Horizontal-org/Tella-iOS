//
//  NextcloudMetadata.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 31/7/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

struct NextcloudMetadata {
    var fileId : String?
    var directory : String
    var fileName : String
    var fileSize : Int
    var remoteFolderName : String
    var serverURL : String
    var chunkFolder: String
    var chunkFiles: [(fileName: String, size: Int64)] = []
}
