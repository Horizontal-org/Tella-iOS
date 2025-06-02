//
//  DropboxUploadResponse.swift
//  Tella
//
//  Created by gus valbuena on 10/2/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

enum DropboxUploadResponse {
    case initial
    case progress(progressInfo: UploadProgressInfo)
    case folderCreated(folderName: String)
    case descriptionSent
}

