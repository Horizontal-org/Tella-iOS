//
//  FileListViewModel.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI
import Combine

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
    
    
    @Published var shouldReloadVaultFiles = false
    @Published var viewType: FileViewType = FileViewType.list
    @Published var vaultFileStatusArray : [VaultFileStatus] = []
    @Published var folderPathArray: [VaultFileDB] = []
    @Published var selectingFiles = false
    @Published var showFileDetails = false
    @Published var showFileInfoActive = false
    @Published var showingMoveFileView = false
    @Published var showingCamera = false
    @Published var showingMicrophone = false
    @Published var showingImportDocumentPicker = false
    @Published var showingImagePicker = false
    @Published var vaultFiles : [VaultFileDB] = []
    
    
    var appModel: MainAppModel
    var filterType: FilterType
    var oldParentFile : VaultFileDB?
    var fileActionSource : FileActionSource = .listView
    var fileListType : FileListType = .fileList
    var resultFile : Binding<[VaultFileDB]?>?
    
    var shouldAddEditView: Bool {
        switch currentSelectedVaultFile?.tellaFileType {
        case .audio, .image, .video : return true
        default: return false
        }
    }

    var rootFile : VaultFileDB? {
        didSet {
            getFiles()
        }
    }
    
    var sortBy: FileSortOptions = FileSortOptions.nameAZ {
        didSet {
            getFiles()
        }
    }
    
    var isAllFilesType: Bool {
      return  filterType == .all && self.rootFile == nil
    }
    
    var selectedFiles : [VaultFileDB] {
        return vaultFileStatusArray.filter{$0.isSelected}.compactMap{$0.file}
    }
    
    var currentSelectedVaultFile : VaultFileDB? {
        let files = vaultFileStatusArray.filter({$0.isSelected})
        if files.count > 0 {
            return files[0].file
        }
        return nil
    }
    
    var filePath : String {
        let rootPath = LocalizableVault.rootDirectoryName.localized + (folderPathArray.count > 0 ? "/" : "")
        return  rootPath + self.folderPathArray.compactMap{$0.name}.joined(separator: "/")
    }
    
    var selectedItemsNumber : Int {
        return vaultFileStatusArray.filter{$0.isSelected}.count
    }
    
    var selectedItemsTitle : String {
        let itemString = selectedItemsNumber == 1 ? LocalizableVault.itemAppBar.localized : LocalizableVault.itemsAppBar.localized
        return String.init(format: itemString, selectedItemsNumber)
    }
    
    var fileActionsTitle: String {
        selectedFiles.count == 1 ? selectedFiles[0].name : selectedItemsTitle
    }
    
    var shouldActivateShare : Bool {
        (!selectedFiles.contains{$0.type == .directory})
    }
    
    var shouldActivateSaveToDevice : Bool {
        !selectedFiles.contains{$0.type == .directory}
    }
    
    var shouldActivateRename : Bool {
        selectedFiles.count == 1
    }
    var shouldActivateEditFile : Bool {
        selectedFiles.count == 1 && shouldAddEditView
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
    
    var shouldShowSelectButton: Bool {
        fileListType == .selectFiles
    }

    var selectButtonEnabled: Bool {
        resultFile?.wrappedValue?.isEmpty ?? false
    }
    
    var shouldShowShareButton : Bool {
        shouldActivateShare && selectedItemsNumber > 0
    }

    
    var fileActionItems: [ListActionSheetItem] {
        
        var items: [ListActionSheetItem] = []
        if !shouldHideViewsForGallery && isAllFilesType {
            items.append(ListActionSheetItem(imageName: "move-icon",
                                                             content: LocalizableVault.moreActionsMoveSheetSelect.localized,
                                                             type: FileActionType.move))
        }
        
        if shouldActivateRename  {
            items.append(ListActionSheetItem(imageName: "edit-icon",
                                                             content: LocalizableVault.moreActionsRenameSheetSelect.localized,
                                                             type: FileActionType.rename))
        }
        if shouldActivateEditFile {
            items.append(ListActionSheetItem(imageName: "file.edit",
                                                             content: LocalizableVault.moreActionsEditSheetSelect.localized,
                                                             type: FileActionType.edit))

            
        }

        
        if shouldActivateShare {
            items.append(ListActionSheetItem(imageName: "share-icon",
                                             content: LocalizableVault.moreActionsShareSheetSelect.localized,
                                             type: FileActionType.share))
        }
        if shouldActivateShare {
            items.append(ListActionSheetItem(imageName: "save-icon",
                                             content: LocalizableVault.moreActionsSaveSheetSelect.localized,
                                                             type: FileActionType.save))
        }
        
        if shouldActivateFileInformation {
            items.append(ListActionSheetItem(imageName: "info-icon",
                                                             content: LocalizableVault.moreActionsFileInformationSheetSelect.localized,
                                                             type: FileActionType.info))
        }

        items.append(ListActionSheetItem(imageName: "delete-icon",
                                                         content: LocalizableVault.moreActionsDeleteSheetSelect.localized,
                                                         type: FileActionType.delete))
        
        return items
    }
    
    var  manageFilesItems: [ListActionSheetItem] {
        
        let allManageFilesItems = [
            
            ListActionSheetItem(imageName: "camera-icon",
                                content: LocalizableVault.manageFilesTakePhotoVideoSheetSelect.localized,
                                type: ManageFileType.camera),
            ListActionSheetItem(imageName: "mic-icon",
                                content: LocalizableVault.manageFilesRecordAudioSheetSelect.localized,
                                type: ManageFileType.recorder),
            ListActionSheetItem(imageName: "upload-icon",
                                content: LocalizableVault.manageFilesImportFromDeviceSheetSelect.localized,
                                type: ManageFileType.fromDevice),
            filterType == .all ? ListActionSheetItem(imageName: "new_folder-icon",
                                                     content: LocalizableVault.manageFilesCreateNewFolderSheetSelect.localized,
                                                     isActive: filterType == .all,
                                                     type: ManageFileType.folder) : nil
            
        ]
        
        return allManageFilesItems.compactMap({$0})
    }
    
    private var cancellable: Set<AnyCancellable> = []
    
    init(
        appModel:MainAppModel,
        filterType:FilterType = .all,
        rootFile:VaultFileDB? = nil,
        fileActionSource : FileActionSource = .listView,
        fileListType : FileListType = .fileList,
        resultFile : Binding<[VaultFileDB]?>? = nil,
        selectedFile: VaultFileDB? = nil
    ) {
        
        self.appModel = appModel
        self.filterType = filterType
        self.rootFile = rootFile
        self.oldParentFile = rootFile
        self.fileActionSource = fileActionSource
        self.fileListType = fileListType
        self.resultFile = resultFile
        
        getFiles()
        initVaultFileStatusArray()
        updateViewType()
        bindReloadVaultFiles()
        if let selectedFile {
            updateSingleSelection(for: selectedFile)
            showFileDetails = true
        }
    }
    
    func resetSelectedItems() {
        if !showFileDetails {
            _ = vaultFileStatusArray.compactMap{$0.isSelected = false}
            self.objectWillChange.send()
        }
    }
    
    func selectAll() {
        self.vaultFileStatusArray.forEach{$0.isSelected = true}
        self.objectWillChange.send()
    }
    
    func initVaultFileStatusArray() {
        vaultFileStatusArray.removeAll()
        vaultFiles.forEach{vaultFileStatusArray.append(VaultFileStatus(file: $0, isSelected: false))}
    }

    func updateSelection(for file:VaultFileDB) {
        if let index = self.vaultFileStatusArray.firstIndex(where: {$0.file == file }) {
            vaultFileStatusArray[index].isSelected = !vaultFileStatusArray[index].isSelected
            self.objectWillChange.send()
        }
    }
    
    func updateSingleSelection(for file:VaultFileDB) {
        vaultFileStatusArray.removeAll()
        vaultFileStatusArray.append(VaultFileStatus(file: file, isSelected: true))
        
    }
    
    func getStatus(for file:VaultFileDB) -> Bool   {
        if let index = self.vaultFileStatusArray.firstIndex(where: {$0.file == file }) {
            return vaultFileStatusArray[index].isSelected
        }
        return false
    }
    
    func initFolderPathArray(for file:VaultFileDB) {
        if let index = self.folderPathArray.firstIndex(of: file) {
            self.folderPathArray.removeSubrange(index + 1..<self.folderPathArray.endIndex)
        }
    }
    
    func initFolderPathArray() {
        guard let oldRootFile = self.oldParentFile else {
            return
        }
        if let index = self.folderPathArray.firstIndex(of: oldRootFile) {
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
    
    func showFileDetails(file:VaultFileDB) {
        if file.type == .directory {
            if (showingMoveFileView && !selectedFiles.contains(file)) || !(showingMoveFileView) {
                rootFile = file
                folderPathArray.append(file)
                self.getFiles()
            }
            
        } else {
            if !showingMoveFileView {
                updateSingleSelection(for: file)
                showFileDetails = true
            }
        }
        
    }

    func attachFiles() {
        DispatchQueue.main.async {
            self.resultFile?.wrappedValue = self.selectedFiles
        }
    }
    
    func bindReloadVaultFiles() {
        self.$shouldReloadVaultFiles.sink(receiveValue: { shouldReloadVaultFiles in
            if shouldReloadVaultFiles {
                self.getFiles()
            }
        }).store(in: &cancellable)
    }
    
}

extension FileListViewModel {
   
    func getFiles() {
        vaultFiles = appModel.vaultFilesManager?.getVaultFiles(parentId: self.rootFile?.id, filter: self.filterType, sort: self.sortBy) ?? []
    }
    
    func getVideoFiles() -> [VaultFileDB] {
        return appModel.vaultFilesManager?.getVaultFiles(parentId: self.rootFile?.id, filter: .video, sort: self.sortBy) ?? []
    }

    func addFolder(name: String) {
        let addFolderFileResult = appModel.vaultFilesManager?.addFolderFile(name: name, parentId: self.rootFile?.id)
        if case .success = addFolderFileResult {
            DispatchQueue.main.async {
                self.getFiles()
            }
        }
    }
    
    func moveFiles() {
        let selectedFilesIds = selectedFiles.compactMap({$0.id})
        let moveVaultFileResult = appModel.vaultFilesManager?.moveVaultFile(fileIds: selectedFilesIds, newParentId: rootFile?.id)
        if case .success = moveVaultFileResult {
            DispatchQueue.main.async {
                self.getFiles()
            }
        }
    }
    
    func renameSelectedFile() {
        let renameVaultFileResult = appModel.vaultFilesManager?.renameVaultFile(id: selectedFiles[0].id, name: selectedFiles[0].name)
        if case .success = renameVaultFileResult {
            getFiles()
        }
    }
    
  

    func filesAreUsedInConnections() -> Bool {
        guard let database = appModel.tellaData?.database else { return false }
        let fileIds = selectedFiles.compactMap { $0.id }
        return database.checkFilesInConnections(ids: fileIds)
    }
    
    func deleteSelectedFiles() {
        let deleteVaultFileResult = appModel.vaultFilesManager?.deleteVaultFile(vaultFiles: selectedFiles)
        if case .success = deleteVaultFileResult {
            getFiles()
        }
    }
    
    func clearTmpDirectory() {
        appModel.vaultManager.clearTmpDirectory()
    }
    
    func getDataToShare() -> [Any] {
        appModel.vaultManager.loadVaultFilesToURL(files: selectedFiles)
    }

}

extension FileListViewModel {
    static func stub() -> FileListViewModel {
        return FileListViewModel(appModel: MainAppModel.stub(), filterType: .all, rootFile: VaultFileDB.stub())
    }
}

extension FileListViewModel {
    var deleteConfirmation: DeleteConfirmation {
        let selectedFolders = selectedFiles.filter { $0.type == .directory }
        let fileCount = selectedFiles.count - selectedFolders.count
        let  totalFilesInsideFolders = self.appModel.vaultFilesManager!.getVaultFile(vaultFilesFolders: selectedFolders).count

        let selectionCountDetails = SelectionCountDetails(fileCount: fileCount,
                            foldersCount: selectedFolders.count,
                            filesInsideFoldersCount: totalFilesInsideFolders)
            
        return DeleteConfirmation(selectionCountDetails: selectionCountDetails)
    }
}
