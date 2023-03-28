//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class CameraViewModel: ObservableObject {
    
    // MARK: - Public properties
    
    var resultFile : Binding<[VaultFile]?>?
    
    @Published var lastImageOrVideoVaultFile :  VaultFile?
    @Published var isRecording : Bool = false
    @Published var formattedCurrentTime : String = "00:00:00"
    @Published var currentTime : TimeInterval = 0.0
    
    
    var imageData : Data?
    var image : UIImage?
    
    var videoURL : URL?
    var mainAppModel: MainAppModel?
    
    var rootFile: VaultFile
    
    // MARK: - Private properties
    
    private var cancellable: Set<AnyCancellable> = []
    private var timer = Timer()
    
    // MARK: - Public functions
    
    init(mainAppModel: MainAppModel,
         rootFile: VaultFile,
         resultFile : Binding<[VaultFile]?>? = nil ) {
        
        self.mainAppModel = mainAppModel
        self.rootFile = rootFile
        
        self.lastImageOrVideoVaultFile = mainAppModel.vaultManager.root.files.sorted(by: .newestToOldest, folderPathArray: [], root: rootFile, fileType: [.image, .video]).first
        
        mainAppModel.vaultManager.progress.progress.sink { value in
            if value == 1 {
                
// mainAppModel.vaultManager.clearTmpDirectory()
            }
        }.store(in: &cancellable)
        
        self.resultFile = resultFile
    }
    
    func saveImage()   {
        guard let imageData = image?.fixedOrientation()?.pngData() else { return  }
        guard let url = mainAppModel?.saveDataToTempFile(data: imageData, pathExtension: "png") else { return  }
        Task {
            
            do { let file = try await mainAppModel?.add(files: [url],
                                                        to: rootFile,
                                                        type: .image)
                
                DispatchQueue.main.async {
                    self.resultFile?.wrappedValue = file
                    self.lastImageOrVideoVaultFile = file?.first
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let file = file?.first {
                        self.mainAppModel?.sendAutoReportFile(file: file)
                    }
                }

            }
            catch {
                
            }
        }
    }
    
    func saveVideo()  {
        guard let videoURL = videoURL else { return  }
        
        Task {
            
            do { let file = try await mainAppModel?.add(files: [videoURL],
                                                        to: rootFile,
                                                        type: .video)
                DispatchQueue.main.async {
                    self.resultFile?.wrappedValue = file
                    self.lastImageOrVideoVaultFile = file?.first
                }
            }
            catch {
                
            }
        }
    }
    
    func initialiseTimerRunning() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
    }
    
    func invalidateTimerRunning() {
        self.timer.invalidate()
        currentTime = 0.0
        self.formattedCurrentTime = currentTime.stringFromTimeInterval()
    }
    
    // MARK: - Private functions
    
    
    @objc private func timerRunning() {
        currentTime = currentTime + 1
        self.formattedCurrentTime = currentTime.stringFromTimeInterval()
    }
}
