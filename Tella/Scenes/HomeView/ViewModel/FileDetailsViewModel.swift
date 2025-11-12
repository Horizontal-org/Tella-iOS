//
//  QuickLookViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

final class FileDetailsViewModel: ObservableObject {
    
    var mainAppModel: MainAppModel?
    var currentFile: VaultFileDB?
    
    var urlDocument: URL?
    var data : Data?
    
    @Published var documentIsReady = false
    
    var shouldAddEditView: Bool {
        switch currentFile?.tellaFileType {
        case .audio, .image, .video: return true
        default: return false
        }
    }
    
    init(mainAppModel: MainAppModel?, currentFile: VaultFileDB?) {
        self.mainAppModel = mainAppModel
        self.currentFile = currentFile
        loadDocument()
    }
    
    func loadDocument() {
        
        documentIsReady = false
        
        guard let currentFile else { return }
        
        DispatchQueue.main.async {
            
            switch currentFile.tellaFileType {
                
            case .audio, .image:
                self.data = self.mainAppModel?.vaultManager.loadFileData(file: currentFile)
            case .video:
                break
            default:
                self.urlDocument = self.mainAppModel?.vaultManager.loadVaultFileToURL(file: currentFile)
            }
            
            self.documentIsReady = true
        }
    }
    
    func deleteTmpFile() {
        guard let url = self.urlDocument else {return}
        mainAppModel?.vaultManager.deleteFiles(files: [url])
    }
}
