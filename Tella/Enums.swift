//
//  Enums.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation

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
    case MAIN, CAMERA, COLLECT, RECORD, SETTINGS, GALLERY, CRYPTO, AUTH
}

enum SettingsEnum{
    case MAIN, CHANGE
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
    case VIDEO = "MOV"
    case PDF = "pdf"
}

enum KeyEnum {
    case META_PRIVATE
    case META_PUBLIC
    case PUBLIC
    case PRIVATE
    
    public func toKeyFileEnum() -> KeyFileEnum? {
        switch (self) {
        case .META_PRIVATE:
            return nil
        case .META_PUBLIC:
            return .META_PUBLIC
        case .PUBLIC:
            return .PUBLIC
        case .PRIVATE:
            return .PRIVATE
        }
    }
}

enum KeyFileEnum: String {
    case META_PUBLIC = "meta-pub-key.txt"
    case PUBLIC = "pub-key.txt"
    case PRIVATE = "priv-key.txt"
    
    public func toPath() -> String {
        return "\(TellaFileManager.rootDir)/keys/\(self.rawValue)"
    }
}

enum PasswordTypeEnum: String {
    case BIOMETRIC = "biometric"
    case PASSWORD = "password"
    case PASSCODE = "passcode"
    
    public func toFlag() -> SecAccessControlCreateFlags {
        switch(self) {
        case .BIOMETRIC:
            return .biometryAny
        case .PASSWORD:
            return .applicationPassword
        case .PASSCODE:
            return .devicePasscode
        }
    }
}


