//
//  DeleteConfirmation.swift
//  Tella
//
//  Created by gus valbuena on 2/6/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

struct SelectionCountDetails {
     var fileCount : Int
     var foldersCount : Int
     var filesInsideFoldersCount : Int
 }

enum DeleteConfirmation {
    case singleFolder(Int)  // Int represents the number of files in the folder
    case multipleFolders(Int, Int) // First Int is folder count, second is total file count
    case singleFile
    case multiple(Int) // Int is the total count of files and folders
    
    init(selectionCountDetails: SelectionCountDetails) {
        switch (selectionCountDetails.fileCount, selectionCountDetails.foldersCount) {
        case (0, 1):
            self = .singleFolder(selectionCountDetails.filesInsideFoldersCount)
        case (0, _):
            self =  .multipleFolders(selectionCountDetails.foldersCount, selectionCountDetails.filesInsideFoldersCount)
        case (1, 0):
            self =  .singleFile
        default:
            self =  .multiple(selectionCountDetails.fileCount + selectionCountDetails.filesInsideFoldersCount)
        }
    }

    var title: String {
        switch self {
        case .singleFolder:
            return LocalizableVault.deleteFolderSheetTitle.localized
        case .multipleFolders:
            return LocalizableVault.deleteFoldersSheetTitle.localized
        case .singleFile:
            return LocalizableVault.deleteFileSheetTitle.localized
        case .multiple:
            return LocalizableVault.deleteFilesSheetTitle.localized
        }
    }

    var message: String {
        switch self {
        case .singleFolder(let fileCount):
            return folderMessageForSingleFolder(fileCount)
        case .multipleFolders(let folderCount, let fileCount):
            return folderMessageForMultipleFolders(folderCount, fileCount)
        case .singleFile:
            return LocalizableVault.deleteFileSheetExpl.localized
        case .multiple(let totalCount):
            return String(format: LocalizableVault.deleteFilesSheetExpl.localized, totalCount)
        }
    }

    private func folderMessageForSingleFolder(_ totalFiles: Int) -> String {
        if totalFiles == 1 {
            return LocalizableVault.deleteFolderSingleFileSheetExpl.localized
        }
        return String(format: LocalizableVault.deleteFolderSheetExpl.localized, totalFiles)
    }

    private func folderMessageForMultipleFolders(_ folderCount: Int, _ totalFiles: Int) -> String {
        if totalFiles == 1 {
            return String(format: LocalizableVault.deleteFoldersSingleFileSheetExpl.localized, totalFiles)
        }
        return String(format: LocalizableVault.deleteFoldersSheetExpl.localized, folderCount, totalFiles)
    }
}
