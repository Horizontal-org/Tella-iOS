//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Photos

class PhotoVideoViewModel : ObservableObject {
    
    var mainAppModel : MainAppModel
    var folderPathArray: [VaultFile] = []
    var  resultFile : Binding<[VaultFile]?>?
    
    init(mainAppModel: MainAppModel,
         folderPathArray: [VaultFile],
         resultFile : Binding<[VaultFile]?>? ) {
        
        self.mainAppModel = mainAppModel
        self.folderPathArray = folderPathArray
        self.resultFile = resultFile
    }
    
    func add(files: [URL], type: TellaFileType) {
        Task {
            
            do { let vaultFile = try await self.mainAppModel.add(files: files,
                                                                 to: self.mainAppModel.vaultManager.root,
                                                                 type: type,
                                                                 folderPathArray: self.folderPathArray)
                
                if mainAppModel.importOption == .deleteOriginal {
                    removeFiles(files: files)
                }
                DispatchQueue.main.async {
                    
                    self.resultFile?.wrappedValue = vaultFile
                }
            }
            catch {
                
            }
        }
    }
    
    func add(image: UIImage , type: TellaFileType, pathExtension:String?, originalUrl: URL?) {
        guard let data = image.fixedOrientation()?.pngData() else { return }
        guard let url = mainAppModel.vaultManager.saveDataToTempFile(data: data, pathExtension: pathExtension ?? "png") else { return  }
        Task {
            
            do { let vaultFile = try await self.mainAppModel.add(files: [url],
                                                                 to: self.mainAppModel.vaultManager.root,
                                                                 type: type,
                                                                 folderPathArray: self.folderPathArray)
                
                //remove originalURL from phone
                
                if mainAppModel.importOption == .deleteOriginal {
                    let imageUrls = [originalUrl].compactMap{$0}
                    removeOriginalImage(imageUrls: imageUrls)
                    
                }
                DispatchQueue.main.async {
                    self.resultFile?.wrappedValue = vaultFile
                }
            }
            catch {
                
            }
        }
    }
    
    func removeOriginalImage(imageUrls: [URL]) {
        PHPhotoLibrary.shared().performChanges( {
            let imageAssetToDelete = PHAsset.fetchAssets(withALAssetURLs: imageUrls, options: nil)
                PHAssetChangeRequest.deleteAssets(imageAssetToDelete)
                },
                completionHandler: { success, error in
            print("Finished deleting asset. %@", (success ? "Success" : error as Any))
            })
    }
    
    func removeFiles(files: [URL]) {
        for file in files {
            do {
                try FileManager.default.removeItem(at: file)
            } catch {
                print("Error deleting file: \(error.localizedDescription)")
            }
        }
    }
}
