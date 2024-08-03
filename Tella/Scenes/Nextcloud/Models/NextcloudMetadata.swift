//
//  NextcloudMetadata.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 31/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct NextcloudMetadata {
    var fileId : String?
    var directory : String
    var fileName : String
    var remoteFolderName : String
    var serverURL : String
    var chunkFolder: String
    var chunkFiles: [(fileName: String, size: Int64)] = []
}
