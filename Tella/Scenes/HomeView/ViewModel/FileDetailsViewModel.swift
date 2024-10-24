//
//  QuickLookViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

final class FileDetailsViewModel: ObservableObject {
    
    var appModel: MainAppModel?
    var currentFile: VaultFileDB?
    
    var urlDocument: URL?
    var data : Data?
    
    @Published var documentIsReady = false
    
    var shouldAddEditView: Bool {
        switch currentFile?.tellaFileType {
        case .audio, .image : return true
        default: return false
        }
    }
    
    init(appModel: MainAppModel?, currentFile: VaultFileDB?) {
        self.appModel = appModel
        self.currentFile = currentFile
        loadDocument()
    }
    
    func loadDocument() {
        
        documentIsReady = false
        
        guard let currentFile else { return }
        
        DispatchQueue.main.async {
            
            switch currentFile.tellaFileType {
                
            case .audio, .image:
                self.data = self.appModel?.vaultManager.loadFileData(file: currentFile)
            case .video:
                break
            default:
                self.urlDocument = self.appModel?.vaultManager.loadVaultFileToURL(file: currentFile)
            }
            
            self.documentIsReady = true
        }
    }
    
    func deleteTmpFile() {
        guard let url = self.urlDocument else {return}
        appModel?.vaultManager.deleteFiles(files: [url])
    }
}
