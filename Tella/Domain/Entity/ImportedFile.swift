//
//  ImportedFile.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import MobileCoreServices
import Photos

struct ImportedFile {
    var type: MediaType?
    var urlFile: URL?
    var asset : PHAsset? = nil
    var shouldPreserveMetadata : Bool = false
}
