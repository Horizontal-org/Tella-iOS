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
    
    @Published var sortBy: FileSortOptions = FileSortOptions.nameAZ
    @Published var viewType: FileViewType = FileViewType.list
    
    @Published var vaultFileStatusArray : [VaultFileStatus] = []
    @Published var folderArray: [VaultFile] = []
    
    @Published var showingSortFilesActionSheet = false
    @Published var selectingFiles = false
    @Published var showingFileActionMenu = false
    @Published var showFileDetails = false
    @Published var showFileInfoActive = false
    @Published var showingProgressView = false
    @Published var showingMoveFileView = false
    @Published var showingShareFileView = false
    
    var selectedFiles : [VaultFile] {
        return vaultFileStatusArray.filter{$0.isSelected}.compactMap{$0.file}
    }
    
    var currentSelectedVaultFile : VaultFile? {
        let files = vaultFileStatusArray.filter({$0.isSelected})
        if files.count > 0 {
            return files[0].file
        }
        return nil
    }
    
    var filePath : String {
        let rootPath = "Tella" + (folderArray.count > 0 ? "/" : "")
        return  rootPath + self.folderArray.compactMap{$0.fileName}.joined(separator: "/")
    }
    
    var selectedItemsNumber : Int {
        return vaultFileStatusArray.filter{$0.isSelected}.count
    }
    
    var selectedItemsTitle : String {
        return "\(selectedItemsNumber) items"
    }
    
    var fileActionsTitle: String {
        selectedFiles.count == 1 ? selectedFiles[0].fileName : selectedItemsTitle
    }
    
    var shouldActivateShare : Bool {
        (!selectedFiles.contains{$0.type == .folder})
    }
    
    var shouldActivateSaveToDevice : Bool {
        !selectedFiles.contains{$0.type == .folder}
    }
    
    var shouldActivateRename : Bool {
        selectedFiles.count == 1
    }
    
    var shouldActivateFileInformation : Bool {
        selectedFiles.count == 1
    }
    
    var shouldHideNavigationBar : Bool {
        return selectingFiles || showingMoveFileView
    }
    
    var filesAreAllSelected : Bool {
        return vaultFileStatusArray.filter{$0.isSelected == true}.count == vaultFileStatusArray.count
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
        self.objectWillChange.send()
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
    
    func updateSingleSelection(for file:VaultFile) {
        self.resetSelectedItems()
        
        if let index = self.vaultFileStatusArray.firstIndex(where: {$0.file == file }) {
            vaultFileStatusArray[index].isSelected = !vaultFileStatusArray[index].isSelected
        }
    }
    
    func getStatus(for file:VaultFile) -> Bool   {
        if let index = self.vaultFileStatusArray.firstIndex(where: {$0.file == file }) {
            return vaultFileStatusArray[index].isSelected
        }
        return false
    }
    
    func initSelectedFiles()  {
        _ = self.vaultFileStatusArray.compactMap{$0.isSelected = false}
    }
    
    func add(files: [URL], type: FileType) {
        appModel.add(files: files, to: self.rootFile, type: type)
    }
    
    func add(image: UIImage , type: FileType, pathExtension:String?) {
        guard let data = image.pngData() else { return }
        guard let url = appModel.vaultManager.saveDataToTempFile(data: data, pathExtension: pathExtension ?? "png") else { return  }
        appModel.add(files: [url], to: self.rootFile, type: type)
    }
    
    func add(folder: String) {
        appModel.add(folder: folder , to: self.rootFile)
    }
    
    func moveFiles() {
        appModel.move(files: selectedFiles, from: oldRootFile, to: rootFile)
    }
    
    func clearTmpDirectory() {
        appModel.clearTmpDirectory()
    }
    
    func getDataToShare() -> [Any] {
        appModel.getFilesForShare(files: selectedFiles)
    }
    
}

extension FileListViewModel {
    static func stub() -> FileListViewModel {
        return FileListViewModel(appModel: MainAppModel(), fileType: [.folder], rootFile: VaultFile.stub(type: .folder))
    }
}
