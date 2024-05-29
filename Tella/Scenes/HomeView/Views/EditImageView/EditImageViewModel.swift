//
//  EditImageViewModel.swift
//  Tella
//
//  Created by RIMA on 16/5/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//
import SwiftUI

class EditImageViewModel: ObservableObject {
    
    lazy var imageToEdit: Binding<UIImage> = Binding(
        get: { return UIImage(data: self.data ?? Data(), scale: 1) ?? UIImage() },
        set: {self.croppedImageData = $0.jpegData(compressionQuality: 0.5) }
    )
    
    @ObservedObject private var fileListViewModel : FileListViewModel
    @Published var isDataLoaded = false
    private var croppedImageData: Data?
    private var mainAppModel: MainAppModel
    private var currenFile: VaultFileDB?
    private var data: Data?
    
    init(mainAppModel: MainAppModel,
         fileListViewModel: FileListViewModel) {
        self.fileListViewModel = fileListViewModel
        self.mainAppModel = mainAppModel
        self.currenFile = fileListViewModel.currentSelectedVaultFile
    }
    
    func loadFile() {
        guard let file = currenFile,
              let loadedData = self.mainAppModel.vaultManager.loadFileData(file: file) else { return }
        self.data = loadedData
        isDataLoaded = true
    }
    
    func saveChanges() {
        guard let fileExtension = currenFile?.fileExtension else { return }
        let url = mainAppModel.vaultManager.saveDataToTempFile(data: croppedImageData,
                                                               pathExtension: fileExtension)
        // save in tempFile
        guard let url else {
            return
        }
        self.mainAppModel.addVaultFile(importedFiles: [ImportedFile(urlFile: url)],
                                       parentId: fileListViewModel.rootFile?.id,
                                       shouldReloadVaultFiles : $fileListViewModel.shouldReloadVaultFiles)
    }
    
}

