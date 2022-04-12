//
//  FileListViewModel.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

enum FileActionSource {
    case details
    case listView
}

enum FileListType {
    case cameraGallery
    case recordList
    case fileList
}

class FileListViewModel: ObservableObject {
    
    var appModel: MainAppModel
    var fileType: [FileType]?
    var rootFile : VaultFile
    var oldRootFile : VaultFile
    var fileActionSource : FileActionSource = .listView
    var fileListType : FileListType = .fileList
    
    @Published var sortBy: FileSortOptions = FileSortOptions.nameAZ
    @Published var viewType: FileViewType = FileViewType.list
    
    @Published var vaultFileStatusArray : [VaultFileStatus] = []
    @Published var folderPathArray: [VaultFile] = []
    
    @Published var showingSortFilesActionSheet = false
    @Published var selectingFiles = false
    @Published var showingFileActionMenu = false
    @Published var showFileDetails = false
    @Published var showFileInfoActive = false
    @Published var showingProgressView = false
    @Published var showingMoveFileView = false
    @Published var showingShareFileView = false
    @Published var showingCamera = false
    @Published var showingMicrophone = false
    
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
        let rootPath = "Tella" + (folderPathArray.count > 0 ? "/" : "")
        return  rootPath + self.folderPathArray.compactMap{$0.fileName}.joined(separator: "/")
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
        return selectingFiles || showingMoveFileView || showingCamera || showingMicrophone
    }
    
    var filesAreAllSelected : Bool {
        return vaultFileStatusArray.filter{$0.isSelected == true}.count == vaultFileStatusArray.count
    }
    var shouldHideViewsForGallery: Bool {
        return (fileListType == .cameraGallery || fileListType == .recordList)
    }
    
    var fileActionItems: [ListActionSheetItem] {
        
        firstFileActionItems.filter{$0.type as! FileActionType == FileActionType.share}.first?.isActive = shouldActivateShare
        secondFileActionItems.filter{$0.type as! FileActionType == FileActionType.rename}.first?.isActive =  shouldActivateRename
        secondFileActionItems.filter{$0.type as! FileActionType == FileActionType.save}.first?.isActive =  shouldActivateShare
        secondFileActionItems.filter{$0.type as! FileActionType == FileActionType.info}.first?.isActive =  shouldActivateFileInformation
        
        var items : [ListActionSheetItem] = []
        items.append(contentsOf: firstFileActionItems.filter{$0.isActive == true})
        
        if (firstFileActionItems.contains(where: {$0.isActive})) {
            items.append(ListActionSheetItem(viewType: .divider, type: FileActionType.none))
        }
        
        items.append(contentsOf: secondFileActionItems.filter{$0.isActive == true})
        return items
    }
    
    init(appModel:MainAppModel, fileType:[FileType]?, rootFile:VaultFile, folderPathArray:[VaultFile]?,fileActionSource : FileActionSource = .listView,fileListType : FileListType = .fileList) {
        
        self.appModel = appModel
        self.fileType = fileType
        self.rootFile = rootFile
        self.oldRootFile = rootFile
        self.folderPathArray = folderPathArray ?? []
        self.fileActionSource = fileActionSource
        self.fileListType = fileListType
        initVaultFileStatusArray()
        updateViewType()
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
        return appModel.vaultManager.root.files.sorted(by: self.sortBy, folderPathArray: folderPathArray, root: self.appModel.vaultManager.root, fileType: self.fileType)
    }
    
    func updateSelection(for file:VaultFile) {
        if let index = self.vaultFileStatusArray.firstIndex(where: {$0.file == file }) {
            vaultFileStatusArray[index].isSelected = !vaultFileStatusArray[index].isSelected
            self.objectWillChange.send()
        }
    }
    
    func updateSingleSelection(for file:VaultFile) {
        vaultFileStatusArray.removeAll()
        vaultFileStatusArray.append(VaultFileStatus(file: file, isSelected: true))
        
    }
    
    func getStatus(for file:VaultFile) -> Bool   {
        if let index = self.vaultFileStatusArray.firstIndex(where: {$0.file == file }) {
            return vaultFileStatusArray[index].isSelected
        }
        return false
    }
    
    func initSelectedFiles() {
        _ = self.vaultFileStatusArray.compactMap{$0.isSelected = false}
    }
    
    func initFolderPathArray(for file:VaultFile) {
        if let index = self.folderPathArray.firstIndex(of: file) {
            self.folderPathArray.removeSubrange(index + 1..<self.folderPathArray.endIndex)
        }
    }
    
    func initFolderPathArray() {
        if let index = self.folderPathArray.firstIndex(of: self.oldRootFile) {
            self.folderPathArray.removeSubrange(index + 1..<self.folderPathArray.endIndex)
        } else {
            self.folderPathArray.removeAll()
        }
    }
    
    func updateViewType()  {
        switch fileListType {
        case .cameraGallery:
            viewType = .grid
        case .recordList:
            viewType = .list
        case .fileList:
            break
        }
    }
    
    func add(files: [URL], type: FileType) {
        appModel.add(files: files, to: self.rootFile, type: type, folderPathArray: folderPathArray)
    }
    
    func add(image: UIImage , type: FileType, pathExtension:String?) {
        guard let data = image.fixedOrientation()?.pngData() else { return }
        guard let url = appModel.vaultManager.saveDataToTempFile(data: data, pathExtension: pathExtension ?? "png") else { return  }
        appModel.add(files: [url], to: self.rootFile, type: type, folderPathArray: folderPathArray)
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
        return FileListViewModel(appModel: MainAppModel(), fileType: [.folder], rootFile: VaultFile.stub(type: .folder), folderPathArray: [])
    }
}
