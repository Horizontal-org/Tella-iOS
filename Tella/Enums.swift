//
//  Enums.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

enum ImageEnum: String {
    case CAMERA = "camera-icon"
    case COLLECT = "collect-icon"
    case GALLERY = "gallery-icon"
    case RECORD = "record-icon"
    case SETTINGS = "settings-icon"
    case SHUTDOWN = "shutdown-icon"
    case BACK = "back-icon"
    case LIST = "list-icon"
    case GRID = "grid-icon"
    case KEY = "key-icon"
    case KEYTYPE = "key-type-icon"
    case PLUS = "plus-icon"
}

enum MainViewEnum {
    case MAIN, CAMERA, COLLECT, RECORD, SETTINGS, GALLERY
}

enum GalleryViewEnum {
    case MAIN, PREVIEW(filepath: String), DOCPICKER, IMAGEPICKER, PICKERPICKER
    
    static func ==(lhs: GalleryViewEnum, rhs: GalleryViewEnum) -> Bool {
        switch lhs {
        case .MAIN:
            if case .MAIN = rhs { return true }
        case .PREVIEW(let filepath):
            if case .PREVIEW(let filepath2) = rhs, filepath == filepath2 { return true }
         case .DOCPICKER:
            if case .DOCPICKER = rhs { return true }
        case .IMAGEPICKER:
            if case .IMAGEPICKER = rhs { return true }
        case .PICKERPICKER:
            if case .PICKERPICKER = rhs { return true }
        }
        return false
    }
}

enum FileTypeEnum: String {
    case IMAGE = "png"
    case TEXT = "txt"
    case VIDEO = "mp4"
    case PDF = "pdf"
    case OTHER = "unknown"
}
