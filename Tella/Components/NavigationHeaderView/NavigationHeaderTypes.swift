//
//  NavigationHeaderEnum.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 21/1/2025.
//  Copyright © 2025 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



enum RightButtonType {
    
    case save
    case validate
    case reload
    case delete
    case editFile
    case more
    case text(text:String)
    case custom
    case none
    
    var imageName: String {
        switch self {
        case .save: return "reports.save"
        case .validate: return "report.select-files"
        case .reload: return "arrow.clockwise"
        case .delete: return "delete-icon-bin"
        case .editFile: return "edit.audio.cut"
        case .more: return "files.more"
        case .text, .custom, .none : return ""
        }
    }
}

enum MiddleButtonType  {
    
    case editFile
    case share
    case none
    
    var imageName: String {
        switch self {
        case .editFile: return "file.edit"
        case .share: return "share-icon"
        case .none: return ""
        }
    }
}

enum BackButtonType {
    
    case back
    case close
    case none

    var imageName: String {
        switch self {
        case .close: return "close"
        case .back: return "back"
        case .none: return ""

        }
    }
}

enum NavigationBarType {
    case inline
    case large
}
