//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

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
    
    func add(files: [URL], type: FileType) {
        Task {
            
            do { let vaultFile = try await self.mainAppModel.add(files: files,
                                                                 to: self.mainAppModel.vaultManager.root,
                                                                 type: type,
                                                                 folderPathArray: self.folderPathArray)
                DispatchQueue.main.async {
                    
                    self.resultFile?.wrappedValue = vaultFile
                }
            }
            catch {
                
            }
        }
    }
    
    func add(image: UIImage , type: FileType, pathExtension:String?) {
        guard let data = image.fixedOrientation()?.pngData() else { return }
        guard let url = mainAppModel.vaultManager.saveDataToTempFile(data: data, pathExtension: pathExtension ?? "png") else { return  }
        Task {
            
            do { let vaultFile = try await self.mainAppModel.add(files: [url],
                                                                 to: self.mainAppModel.vaultManager.root,
                                                                 type: type,
                                                                 folderPathArray: self.folderPathArray)
                DispatchQueue.main.async {
                    self.resultFile?.wrappedValue = vaultFile
                }
            }
            catch {
                
            }
        }
    }
}
