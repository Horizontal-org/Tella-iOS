//
//  FileListViewModel.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI


class FileListViewModel: ObservableObject {
    @Published var showingSortFilesActionSheet = false
    @Published var sortBy: FileSortOptions = FileSortOptions.nameAZ
    
    @Published var showingFileActionMenu = false
    @Published var selectingFiles = false
    @Published var fileActionMenuType: FileActionMenuType = FileActionMenuType.single
    @Published var vaultFileStatusArray : [VaultFileStatus] = []
    @Published var currentSelectedVaultFile : VaultFile?

    @Published var showFileDetails = false

    @Published var showFileInfoActive = false
    
    @Published var viewType: FileViewType = FileViewType.list
    
    @Published var folderArray: [VaultFile] = []
    
    var selectedItemsNumber : Int {
        return vaultFileStatusArray.filter{$0.isSelected}.count
    }
    
    var selectedItems : [VaultFile] {
        if fileActionMenuType == .single {
            guard let currentSelectedVaultFile = currentSelectedVaultFile else { return [] }
            return [currentSelectedVaultFile]
        } else {
            return vaultFileStatusArray.filter{$0.isSelected}.compactMap{$0.file}
        }
    }
    
    var filePath : String {
        let rootPath = "Tella" + (folderArray.count > 0 ? "/" : "")
        return  rootPath + self.folderArray.compactMap{$0.fileName}.joined(separator: "/")
    }
    
    func resetSelectedItems() {
        _ = vaultFileStatusArray.compactMap{$0.isSelected = false}
    }
}

class VaultFileStatus {
    var file : VaultFile
    var isSelected : Bool
    
    init(file : VaultFile, isSelected : Bool) {
        self.file = file
        self.isSelected = isSelected
    }
}
