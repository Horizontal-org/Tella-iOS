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
    
    var tableName: String? {
        return "Home"
    }
}
