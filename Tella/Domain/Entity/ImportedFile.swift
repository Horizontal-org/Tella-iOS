//
//  ImportedFile.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
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
    case heic = "heic"
    case mov = "mov"
}
