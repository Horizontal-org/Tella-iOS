//
//  ImportedFile.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Photos

struct ImportedFile {
    var type: MediaType?
    var urlFile: URL?
    var asset : PHAsset? = nil
    var parentId : String?
    var shouldPreserveMetadata : Bool = false
    var deleteOriginal : Bool = false
    var fileSource : FileSource
}

enum FileSource {
    case phPicker
    case files
    case camera
    case editFile
}

enum FileExtension : String {
    case heic = "HEIC"
    case mov = "mov"
    case mp4 = "mp4"
    case png = "png"
    case jpeg = "jpeg"
}
