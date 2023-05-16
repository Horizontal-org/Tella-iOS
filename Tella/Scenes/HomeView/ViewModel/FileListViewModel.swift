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
    case selectFiles
}

class FileListViewModel: ObservableObject {
    
    var appModel: MainAppModel
    var fileType: [FileType]?
    var rootFile : VaultFile
    var oldRootFile : VaultFile
    var fileActionSource : FileActionSource = .listView
    var fileListType : FileListType = .fileList
    var resultFile : Binding<[VaultFile]?>?
    
    @Published var sortBy: FileSortOptions = FileSortOptions.nameAZ
    @Published var viewType: FileViewType = FileViewType.list
    
    @Published var vaultFileStatusArray : [VaultFileStatus] = []
    @Published var folderPathArray: [VaultFile] = []
    
    @Published var selectingFiles = false
    @Published var showFileDetails = false
    @Published var showFileInfoActive = false
    @Published var showingMoveFileView = false
    @Published var showingShareFileView = false
    @Published var showingCamera = false
    @Published var showingMicrophone = false
    @Published var showingDocumentPicker = false
    @Published var showingImportDocumentPicker = false
    @Published var showingImagePicker = false
    
    
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
        let rootPath = LocalizableVault.rootDirectoryName.localized + (folderPathArray.count > 0 ? "/" : "")
        return  rootPath + self.folderPathArray.compactMap{$0.fileName}.joined(separator: "/")
    }
    
    var selectedItemsNumber : Int {
        return vaultFileStatusArray.filter{$0.isSelected}.count
    }
    
    var selectedItemsTitle : String {
        let itemString = selectedItemsNumber == 1 ? LocalizableVault.itemAppBar.localized : LocalizableVault.itemsAppBar.localized
        return String.init(format: itemString, selectedItemsNumber)
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
        return (selectingFiles || showingMoveFileView || showingCamera || showingMicrophone) && fileListType != .selectFiles
    }
    
    var shouldShowSelectingFilesHeaderView: Bool {
       return selectingFiles && fileListType != .selectFiles
    }
    
    var filesAreAllSelected : Bool {
        return vaultFileStatusArray.filter{$0.isSelected == true}.count == vaultFileStatusArray.count
    }
    var shouldHideViewsForGallery: Bool {
        return (fileListType == .cameraGallery || fileListType == .recordList)
    }
    
    var shouldHideAddFileButton: Bool {
        return fileListType == .cameraGallery || fileListType == .recordList || fileListType == .selectFiles
    }

    var fileActionItems: [ListActionSheetItem] {
        
        firstFileActionItems.filter{$0.type as! FileActionType == FileActionType.share}.first?.isActive = shouldActivateShare
        secondFileActionItems.filter{$0.type as! FileActionType == FileActionType.move}.first?.isActive = !shouldHideViewsForGallery
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
    
    init(appModel:MainAppModel, fileType:[FileType]?, rootFile:VaultFile, folderPathArray:[VaultFile]?,fileActionSource : FileActionSource = .listView,fileListType : FileListType = .fileList, resultFile : Binding<[VaultFile]?>? = nil) {
        
        self.appModel = appModel
        self.fileType = fileType
        self.rootFile = rootFile
        self.oldRootFile = rootFile
        self.folderPathArray = folderPathArray ?? []
        self.fileActionSource = fileActionSource
        self.fileListType = fileListType
        self.resultFile = resultFile
        
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
        case .selectFiles:
            selectingFiles = true
        case .fileList:
            break
        }
    }
    
    func showFileDetails(file:VaultFile) {
        if file.type == .folder {
            if (showingMoveFileView && !selectedFiles.contains(file)) || !(showingMoveFileView) {
                rootFile = file
                folderPathArray.append(file)
            }
            
        } else {
            if !showingMoveFileView {
                updateSingleSelection(for: file)
                showFileDetails = true
            }
        }
        
    }
    
    func add(files: [URL], type: FileType) {
        Task {
            
            do { _ = try await appModel.add(files: files, to: self.rootFile, type: type, folderPathArray: folderPathArray)
            }
            catch {
                
            }
        }
    }
    
    func add(image: UIImage , type: FileType, pathExtension:String?) {
        guard let data = image.fixedOrientation()?.pngData() else { return }
        guard let url = appModel.vaultManager.saveDataToTempFile(data: data, pathExtension: pathExtension ?? "png") else { return  }
        Task {
            
            do { _ = try await appModel.add(files: [url], to: self.rootFile, type: type, folderPathArray: folderPathArray)
                
            }
            catch {
                
            }
        }
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
    
    func attachFiles() {
        DispatchQueue.main.async {
            self.resultFile?.wrappedValue = self.selectedFiles
        }

    }
}

extension FileListViewModel {
    static func stub() -> FileListViewModel {
        return FileListViewModel(appModel: MainAppModel(), fileType: [.folder], rootFile: VaultFile.stub(type: .folder), folderPathArray: [])
    }
}
