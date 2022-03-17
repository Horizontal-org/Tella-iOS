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
    var rootFile : VaultFile
    var oldRootFile : VaultFile

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
    
    @Published var showingMoveFileView = false

    @Published var viewType: FileViewType = FileViewType.list
    
    @Published var folderArray: [VaultFile] = []
   

    
    var selectedFiles : [VaultFile] {
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
    
    var selectedItemsNumber : Int {
        return vaultFileStatusArray.filter{$0.isSelected}.count
    }
    
    var selectedItemsTitle : String {
        return selectedItemsNumber == 1 ? "\(selectedItemsNumber) item" : "\(selectedItemsNumber) items"
    }
    
    var fileActionsTitle: String {
        (fileActionMenuType == .single && selectedFiles.count == 1) ? selectedFiles[0].fileName : selectedItemsTitle
    }

    var shouldActivateShare : Bool {
        (fileActionMenuType == .single && (selectedFiles.count == 1 && selectedFiles[0].type != .folder)) ||
        (fileActionMenuType == .multiple && !selectedFiles.contains{$0.type == .folder})
    }
    
    var shouldActivateSaveToDevice : Bool {
        (fileActionMenuType == .single && (selectedFiles.count == 1 && selectedFiles[0].type != .folder)) ||
        (fileActionMenuType == .multiple && !selectedFiles.contains{$0.type == .folder})
    }

    var shouldActivateRename : Bool {
        (fileActionMenuType == .single) ||
        (fileActionMenuType == .multiple && selectedFiles.count == 1)
    }
    
    var shouldActivateFileInformation : Bool {
        (fileActionMenuType == .single) ||
        (fileActionMenuType == .multiple && selectedFiles.count == 1)
    }
    
    var shouldHideNavigationBar : Bool {
        return selectingFiles || showingMoveFileView
    }
    

    init(appModel:MainAppModel, fileType:[FileType]?, rootFile:VaultFile) {
        self.appModel = appModel
        self.fileType = fileType
        self.rootFile = rootFile
        self.oldRootFile = rootFile
        initVaultFileStatusArray()
    }
    
    func resetSelectedItems() {
        _ = vaultFileStatusArray.compactMap{$0.isSelected = false}
    }
    
    func selectAll() {
        self.vaultFileStatusArray.forEach{$0.isSelected = true}
        self.objectWillChange.send()
    }
    
    func initVaultFileStatusArray() {
        vaultFileStatusArray.removeAll()
        getFiles().forEach{vaultFileStatusArray.append(VaultFileStatus(file: $0, isSelected: false))}
    }
    
    func getFiles() -> [VaultFile]  {
        return appModel.vaultManager.root.files.sorted(by: self.sortBy, folderArray: folderArray, root: self.appModel.vaultManager.root, fileType: self.fileType)
    }
    
    func updateSelection(for file:VaultFile) {
        if let index = self.vaultFileStatusArray.firstIndex(where: {$0.file == file }) {
            vaultFileStatusArray[index].isSelected = !vaultFileStatusArray[index].isSelected
            self.objectWillChange.send()
        }
    }

    func getStatus(for file:VaultFile) -> Bool   {
        if let index = self.vaultFileStatusArray.firstIndex(where: {$0.file == file }) {
            return vaultFileStatusArray[index].isSelected
        }
        return false
    }
    
    func initSelectedFiles()  {
        self.currentSelectedVaultFile = nil
        _ = self.vaultFileStatusArray.compactMap{$0.isSelected = false}
    }
    
    func add(files: [URL], type: FileType) {
        appModel.add(files: files, to: self.rootFile, type: type)
    }
    
    func add(image: UIImage , type: FileType, pathExtension:String?) {
        appModel.add(image: image, to: self.rootFile, type: type, pathExtension: pathExtension ?? "png")
    }
    
    func add(folder: String) {
        appModel.add(folder: folder , to: self.rootFile)
    }

    func moveFiles() {
        appModel.move(files: selectedFiles, from: oldRootFile, to: rootFile)
    }
}

extension FileListViewModel {
    static func stub() -> FileListViewModel {
        return FileListViewModel(appModel: MainAppModel(), fileType: [.folder], rootFile: VaultFile.stub(type: .folder))
    }
}
