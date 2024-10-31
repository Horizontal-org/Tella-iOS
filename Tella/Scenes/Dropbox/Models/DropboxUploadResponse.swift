//
//  DropboxUploadResponse.swift
//  Tella
//
//  Created by gus valbuena on 10/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

enum DropboxUploadResponse {
    case initial
    case progress(progressInfo: UploadProgressInfo)
    case folderCreated(folderName: String)
    case descriptionSent
}

