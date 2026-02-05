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
    case help
    case none
    
    var imageName: ImageResource? {
        switch self {
        case .save: return .reportsSave
        case .validate: return .reportSelectFiles
        case .reload: return .arrowClockwise
        case .delete: return .deleteIconBin
        case .editFile: return .editAudioCut
        case .more: return .filesMore
        case .help: return .nearbySharingHelp
        case .text, .custom, .none : return nil
        }
    }
}

enum MiddleButtonType  {
    
    case editFile
    case share
    case rotate
    case none
    
    var imageName: String {
        switch self {
        case .editFile: return "file.edit"
        case .share: return "share-icon"
        case .rotate: return "edit.rotate"

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
