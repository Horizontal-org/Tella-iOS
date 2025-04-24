//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation

import Combine

class ImportProgress: ObservableObject {
    
    var progressFile = CurrentValueSubject<String, Never>("")
    var progress = CurrentValueSubject<Double, Never>(0.0)
    var totalFiles : Int = 1
    var isFinishing = CurrentValueSubject<Bool, Never>(false)
    
    var currentFile : Int = 1 {
        didSet {
            DispatchQueue.main.async {
                self.progressFile.send("\(self.currentFile)/\(self.totalFiles)")
            }
        }
    }
    
    private var totalTime : TimeInterval = 0.0
    private var timeRemaining : TimeInterval = 0.0
    private var timer = Timer()
    private let bytesImportedPerSecond = 200000000 // Calculated approximately
    private let bytesExportedPerSecond =   7000000 // Calculated approximatively
    
    func start(currentFile: Int = 0, totalFiles: Int = 1, totalSize: Double = 0.0, totalVideosSizeForExport: Double = 0.0) {
        
        DispatchQueue.main.async {
            self.progress.send(0)
            
            self.totalFiles = totalFiles
            self.currentFile = currentFile
            
            // Time necessary to export videos and delete metadata
            let timeForVideoExport = Double(totalVideosSizeForExport) / Double(self.bytesExportedPerSecond)
            
            // Time necessary to import files: preparing files information and encryption
            let timeForFileImport = Double(totalSize) / Double(self.bytesImportedPerSecond)
            
            self.totalTime = timeForFileImport + timeForVideoExport
            self.timeRemaining = self.totalTime
            
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
        }
    }

    func stop() {
        DispatchQueue.main.async {
            self.timer.invalidate()
            self.timeRemaining = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.progress.send(0)
        }
    }
    
    func pause() {
        self.timer.invalidate()
    }
    
    func resume() {
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.timerRunning), userInfo: nil, repeats: true)
    }
    
    func finish() {
        DispatchQueue.main.async {
            self.timeRemaining = 0.0
            self.timer.invalidate()
            self.progress.send(1)
            self.isFinishing.send(true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.progress.send(0)
            self.isFinishing.send(false)

        }
    }
    
    @objc func timerRunning() {
        DispatchQueue.main.async {
            self.timeRemaining -= 0.1
            let progress = 1 - (self.timeRemaining/self.totalTime)
            if (progress >= 0.0 && progress <= 1.0) {
                self.progress.send(progress)
                
            }
        }
    }
}
