//
//  EditImageViewModel.swift
//  Tella
//
//  Created by RIMA on 16/5/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

class EditImageViewModel: ObservableObject {
    
    lazy var imageToEdit: Binding<UIImage> = Binding(
        get: { return UIImage(data: self.data ?? Data(), scale: 1) ?? UIImage() },
        set: { [self] in croppedImageData = getEditedImageData($0)})
    
    @ObservedObject private var fileListViewModel : FileListViewModel
    @Published var isDataLoaded = false
    private var croppedImageData: Data?
    private var mainAppModel: MainAppModel
    private var currenFile: VaultFileDB?
    private var data: Data?
    
    init(fileListViewModel: FileListViewModel) {
        self.fileListViewModel = fileListViewModel
        self.mainAppModel = fileListViewModel.appModel
        self.currenFile = fileListViewModel.currentSelectedVaultFile
    }
    
    func getEditedImageData(_ image: UIImage) -> Data?{
        switch self.currenFile?.fileExtension.uppercased() {
        case FileExtension.heic.rawValue.uppercased():
            return image.heic
        case FileExtension.png.rawValue.uppercased():
            return image.pngData()
        default:
            return image.jpegData(compressionQuality: 1)
        }
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
        self.mainAppModel.addVaultFile(importedFiles: [ImportedFile(urlFile: url,
                                                                    parentId: fileListViewModel.rootFile?.id,
                                                                    fileSource: .editFile)])
    }
    
}

