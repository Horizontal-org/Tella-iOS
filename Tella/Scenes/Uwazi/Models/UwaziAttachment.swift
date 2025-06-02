//
//  UwaziAttachment.swift
//  Tella
//
//  Created by Gustavo on 30/10/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

public struct UwaziAttachment {
    var filename: String
    var data: Data
    var fileExtension: String
    var mimeType: String = ""
    
    public init(filename: String, data: Data, fileExtension: String) {
        self.filename = filename
        self.data = data
        self.fileExtension = fileExtension
        self.mimeType = MIMEType.mime(for: fileExtension)
    }
}
