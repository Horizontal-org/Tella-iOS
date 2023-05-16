//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine
import UIKit
import SwiftUI
import AVFoundation
import AVKit
import AssetsLibrary

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
    func addVideoWithoutExif() {
        guard let videoURL = videoURL else { return  }
            let tmpFileURL = URL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(Int(Date().timeIntervalSince1970))").appendingPathExtension(videoURL.lastPathComponent)
            Task {
                do {
                    guard let url = await self.exportFile(url: videoURL, destinationURL: tmpFileURL) else { return }

                    do { let file = try await mainAppModel?.add(files: [url],
                                                                to: rootFile,
                                                                type: .video)
                        DispatchQueue.main.async {
                            self.resultFile?.wrappedValue = file
                            self.lastImageOrVideoVaultFile = file?.first
                        }
                    }
                }
                catch {

                }
            }
    }

    func addWithExif(methodExifData: [String: Any], pathExtension: String) {
        guard let imageData = self.imageData else { return  }

        Task {
            let exifData = await self.saveImageWithImageData(data: imageData, properties: methodExifData as NSDictionary, pathExtension: "png")
            guard let url = mainAppModel?.saveDataToTempFile(data: exifData as Data, pathExtension: "png") else { return  }
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
    func saveImageWithImageData(data: Data, properties: NSDictionary, pathExtension: String) async -> NSData{

        let imageRef: CGImageSource = CGImageSourceCreateWithData((data as CFData), nil)!
        let uti: CFString = CGImageSourceGetType(imageRef)!
        let dataWithEXIF: NSMutableData = NSMutableData(data: data as Data)
        let destination: CGImageDestination = CGImageDestinationCreateWithData((dataWithEXIF as CFMutableData), uti, 1, nil)!

        CGImageDestinationAddImageFromSource(destination, imageRef, 0, (properties as CFDictionary))
        CGImageDestinationFinalize(destination)
        return dataWithEXIF
    }
    func exportFile(url: URL, destinationURL: URL) async -> URL? {
        let asset = AVAsset(url: url)
        print(asset.metadata)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return nil }
        exportSession.outputURL = destinationURL
        var fileType: AVFileType = .mov
        if  url.pathExtension.lowercased() == "mov" {
            fileType = .mov
        } else if url.pathExtension.lowercased() == "mp4" {
            fileType = .mp4
        } else {
            fileType = .mov
        }
        exportSession.outputFileType = fileType
        exportSession.metadata = nil
        exportSession.metadataItemFilter = .forSharing()
        await exportSession.export()
        if exportSession.status == .completed {
            return destinationURL
        } else {
            return nil
        }
    }
    func getEXIFData(url: URL) -> [String: Any] {
        let fileURL = url
        if let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil) {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
            if let dict = imageProperties as? [String: Any] {
                print(dict)
                return dict
            }
        }
        return [:]
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
