//
//  EditImageViewModel.swift
//  Tella
//
//  Created by RIMA on 16/5/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//
import SwiftUI

class EditImageViewModel: ObservableObject {
    
    lazy var imageToEdit: Binding<UIImage?> = Binding(
        get: { return UIImage(data: self.data, scale: 1) ?? UIImage() },
        set: {self.croppedImageData = $0?.jpegData(compressionQuality: 0.5) ?? Data()}
    )
    
    var fileListViewModel : FileListViewModel
    
    var croppedImageData: Data?
    var mainAppModel: MainAppModel
    var currenFile: VaultFileDB?
    var parentId: String?
    var data: Data
    
    
    init(data: Data,  mainAppModel: MainAppModel,
         fileListViewModel: FileListViewModel,
         currenFile: VaultFileDB? = nil,
         parentId: String? = nil) {
        self.data = data
        self.fileListViewModel = fileListViewModel
        self.mainAppModel = mainAppModel
        self.currenFile = currenFile
        self.parentId = parentId
    }
    
    
    func saveChanges() {
        let url = mainAppModel.vaultManager.saveDataToTempFile(data: croppedImageData
                                                               , pathExtension: currenFile?.fileExtension ?? "")
        // save in tempFile
        guard let url = url else {
            return
        }
        self.mainAppModel.addVaultFile(importedFiles: [ImportedFile(urlFile: url)], parentId: parentId, shouldReloadVaultFiles : .constant(false))
        fileListViewModel.shouldReloadVaultFiles = true
    }
    
}

