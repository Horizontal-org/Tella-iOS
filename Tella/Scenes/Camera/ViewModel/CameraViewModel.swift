//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import UIKit

class CameraViewModel: ObservableObject {
    
    // MARK: - Public properties
    
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
    
    init(mainAppModel: MainAppModel, rootFile: VaultFile ) {
        
        self.mainAppModel = mainAppModel
        self.rootFile = rootFile

        mainAppModel.vaultManager.$root.sink { file in
            self.lastImageOrVideoVaultFile = file.files.sorted(by: .newestToOldest, folderPathArray: [], root: mainAppModel.vaultManager.root, fileType: [.image, .video]).first
        }.store(in: &cancellable)
        
        mainAppModel.vaultManager.progress.progress.sink { value in
            if value == 1 {
                
                mainAppModel.vaultManager.clearTmpDirectory()
            }
        }.store(in: &cancellable)
    }

    func saveImage()   {
        guard let imageData = image?.fixedOrientation()?.pngData() else { return  }
        guard let url = mainAppModel?.saveDataToTempFile(data: imageData, pathExtension: "png") else { return  }

        mainAppModel?.add(files: [url],
                          to: rootFile,
                          type: .image)
    }

    func saveVideo() {
        guard let videoURL = videoURL else { return  }
        mainAppModel?.add(files: [videoURL],
                          to: rootFile,
                          type: .video)
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
