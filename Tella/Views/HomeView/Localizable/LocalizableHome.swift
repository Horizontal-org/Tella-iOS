//
//  LocalizableHome.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

enum LocalizableHome: String, LocalizableDelegate {
    
    // Recent files
    case  recentFiles = "HomeRecentFiles"
    
    case  favoriteForms = "HomeFavoriteForms"
    
    // Tella files
    case  tellaFiles = "HomeTellaFiles"
    case  allFilesItem = "HomeAllFilesItem"
    case  imagesItem = "HomeImagesItem"
    case  videosItem = "HomeVideosItem"
    case  audioItem = "HomeAudioItem"
    case  documentsItem = "HomeDocumentsItem"
    case  othersItem = "HomeOthersItem"
    
    
    // File Info
    
    case  fileInfo = "HomeFileInfoTitle"
    case  fileName = "HomeFileName"
    case  size = "HomeFileSize"
    case  format = "HomeFileFormat"
    case  created = "HomeFileCreated"
    case  resolution = "HomeFileResolution"
    case  length = "HomeFileLength"
    case  filePath = "HomeFilePath"
    
    // Import Progress
    
    case  importProgressTitle = "HomeImportProgressTitle"
    case  importProgressFileImported = "HomeImportProgressFileImported"
    
    // Cancel Import File
    
    case  cancelImportFileTitle = "HomeCancelImportFileTitle"
    case  cancelImportFileMessage = "HomeCancelImportFileMessage"
    case  cancelImportFileBack = "HomeCancelImportFileBack"
    case  cancelImportFileCancelImport = "HomeCancelImportFileCancelImport"
    
    var tableName: String? {
        return "Home"
    }
}
