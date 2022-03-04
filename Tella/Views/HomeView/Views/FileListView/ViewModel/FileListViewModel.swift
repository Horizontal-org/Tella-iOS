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
    
    var appModel: MainAppModel
    
    var fileType: [FileType]?
    
    @Published var showingSortFilesActionSheet = false
    @Published var sortBy: FileSortOptions = FileSortOptions.nameAZ
    
    @Published var showingFileActionMenu = false
    @Published var selectingFiles = false
    @Published var fileActionMenuType: FileActionMenuType = FileActionMenuType.single
    @Published var vaultFileStatusArray : [VaultFileStatus] = []
    @Published var currentSelectedVaultFile : VaultFile?
    
    @Published var showFileDetails = false
    
    @Published var showFileInfoActive = false
    
    @Published var showingProgressView = false
    
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
    
    init(appModel:MainAppModel, fileType:[FileType]?) {
        self.appModel = appModel
        self.fileType = fileType
    }
    
    func resetSelectedItems() {
        _ = vaultFileStatusArray.compactMap{$0.isSelected = false}
    }
    
    func selectAll() {
        self.vaultFileStatusArray.forEach{$0.isSelected = true}
        self.objectWillChange.send()
    }
    
    func getFile() -> [VaultFile]  {
        appModel.vaultManager.root.files.sorted(by: self.sortBy, folderArray: folderArray, root: self.appModel.vaultManager.root, fileType: self.fileType)
    }
}


