//
//  LocalizableHome.swift
//  Tella
//
//  
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import Foundation

enum LocalizableHome: String, LocalizableDelegate {
    
    case appBar = "Home_AppBar"
    case tabBar = "Home_TabBar"
    
    // Recent files
    case recentFilesSubhead = "Home_RecentFiles_Subhead"
    case recentFiles_MoreFiles = "Home_RecentFiles_MoreFiles"
    
    // Tella files
    case tellaFilesSubhead = "Home_TellaFiles_Subhead"
    case tellaFilesAllFiles = "Home_TellaFiles_Action_AllFiles"
    case tellaFilesImages = "Home_TellaFiles_Action_Images"
    case tellaFilesVideos = "Home_TellaFiles_Action_Videos"
    case tellaFilesAudio = "Home_TellaFiles_Action_Audio"
    case tellaFilesDocuments = "Home_TellaFiles_Action_Documents"
    case tellaFilesOthers = "Home_TellaFiles_Action_Others"

    //QuickDelete
    case quickDeleteSwipeTitle = "Home_QuickDelete_Action_Title"
    case quickDeleteActionTitle = "Home_QuickDelete_Action_QuickDelete"
    case quickDeleteActionCancel = "Home_QuickDelete_Action_QuickDeleteDeactivated"

    case uwaziServerTitle = "Uwazi_Home_Server_Title"
    
}
