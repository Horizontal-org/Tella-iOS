//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

import Combine

class ImportProgress {
    
    var progressFile : String = ""
    var progress = CurrentValueSubject<Double, Never>(0.0)
    var totalFiles : Int = 1
    var totalSize : Double = 0.0
    var currentFile : Int = 0 {
        didSet {
            self.progressFile = "\(self.currentFile)/\(self.totalFiles)"
        }
    }

    private var totalTime : Double = 0.0
    private var timeRemaining : Double = 0.0
    private var timer = Timer()
    
    private let sizeImportedPerSecond = 20563727
    
    func start(currentFile : Int = 0, totalFiles : Int = 1, totalSize : Double = 0.0) {
        
        self.currentFile = currentFile
        self.totalFiles = totalFiles
        self.totalSize = totalSize
        
        DispatchQueue.main.async {
            
            self.progress.send(0.0)
            self.progressFile = "\(self.currentFile)/\(self.totalFiles)"
            self.totalTime =  Double(self.totalSize) / Double(self.sizeImportedPerSecond)
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
    
    
    func finish() {
        DispatchQueue.main.async {
            self.timeRemaining = 0.0
            //            self.timerIsOn = false
            self.timer.invalidate()
            self.progress.send(1)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.progress.send(0)
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
