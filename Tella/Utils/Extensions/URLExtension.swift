//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



import AVFoundation
import UIKit
import QuickLook
import ZIPFoundation
import Photos

extension URL {
    
    func resolution() -> CGSize? {
        switch self.fileType {
        case .video:
            return resolutionForVideo()
        case .image:
            return resolutionForImage()
        default:
            return nil
        }
    }
    
    func resolutionForVideo() -> CGSize? {
        guard let track = AVURLAsset(url: self).tracks(withMediaType: AVMediaType.video).first else { return nil }
        return track.naturalSize.applying(track.preferredTransform)
    }
    
    func resolutionForImage() -> CGSize? {
        
        guard let image = UIImage(contentsOfFile: path) else {
            return nil
        }
        
        let width = image.size.width * image.scale
        let height = image.size.height * image.scale
        return CGSize(width: width, height: height)
    }
    
    
    func getDuration() -> Double? {
        let asset = AVAsset(url: self)
        
        let duration = asset.duration
        return CMTimeGetSeconds(duration)
    }
    
    
    var fileType: TellaFileType {
        self.pathExtension.fileType
    }
    
    func thumbnail() async -> Data? {
        
        let imageSize = CGFloat(150.0)
        let compressionQuality = 0.5
        
        let resolutionForImage = resolutionForImage()
        
        var width = CGFloat( resolutionForImage?.width ?? imageSize)
        var height = CGFloat( resolutionForImage?.height ?? imageSize)
        
        let aspectRatio = width/height
        
        width = aspectRatio > 1 ? imageSize : imageSize * aspectRatio
        height = aspectRatio < 1 ? imageSize : imageSize * aspectRatio
        
        let thumbnailSize = CGSize(width: width, height: height)
        
        let thumbnail: UIImage?
        do {
            thumbnail = try await getThumbnail(for: self, size: thumbnailSize, scale: UIScreen.screenScale)
        }catch {
            thumbnail = nil
        }
        guard let thumbnail else { return nil }
        return thumbnail.jpegData(compressionQuality: compressionQuality)
    }
    
    private func getThumbnail(for fileURL: URL, size: CGSize, scale: CGFloat) async throws -> UIImage? {
        
        let request = QLThumbnailGenerator.Request(fileAt: fileURL,
                                                   size: size,
                                                   scale: scale,
                                                   representationTypes: .thumbnail)
        
        let generator = QLThumbnailGenerator.shared
        
        do {
            let generated = try await generator.generateBestRepresentation(for: request)
            return generated.uiImage
        }
        catch {
            return nil
        }
    }
    
    func generateThumbnails(count: Double = 10.0) -> [UIImage] {
        let asset = AVAsset(url: self)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var images: [UIImage] = []
        let duration = asset.duration.seconds
        let interval = duration / count
        
        for i in 0..<Int(count) {
            let time = CMTime(seconds: interval * Double(i), preferredTimescale: 600)
            do {
                let cgImage = try  imageGenerator.copyCGImage(at: time, actualTime: nil)
                images.append(UIImage(cgImage: cgImage))
            } catch {
                debugLog("Error while creating thumbnails")
            }
        }
        return images
    }
    
    func getAVFileType() -> AVFileType {
        switch self.pathExtension.lowercased() {
        case "mp4", "m4a":
            return .mp4
        case "mov", ".qt":
            return .mov
        case "m4v":
            return .m4v
        case "3gpp", "3gp":
            return .mobile3GPP
        case "3gp2", "3g2":
            return .mobile3GPP2
        default:
            return .mov
        }
    }
    /// This function returns the EXIF or metadata as [String: Any] of the image using the URL
    /// - Returns: Metadata
    func getEXIFData() -> [String: Any] {
        if let imageSource = CGImageSourceCreateWithURL(self as CFURL, nil) {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
            if let dict = imageProperties as? [String: Any] {
                return dict
            }
        }
        return [:]
    }
    
    func getOfficeExtension() -> String? {
        
        do {
            var pathExtension : String?
            
            let fileName = self.deletingPathExtension().lastPathComponent
            let tmpFileURL = FileManager().temporaryDirectory.appendingPathComponent(fileName)
            
            try FileManager.default.unzipItem(at: self, to: tmpFileURL)
            
            let tmpDirectory =  DefaultFileManager().contentsOfDirectory(atPath: tmpFileURL)
            
            tmpDirectory.forEach { path in
                
                if path.lastPathComponent == "[Content_Types].xml" {
                    
                    guard let data = DefaultFileManager().contents(atPath: path) else {return}
                    
                    let  contentTypes = OOXMLContentTypeParser().getContentType(from: data).compactMap{$0}
                    
                    let documentContentType = contentTypes.filter { $0.contains(OpenXmlFormats.word.rawValue)}
                    let sheetContentType = contentTypes.filter { $0.contains(OpenXmlFormats.sheet.rawValue)}
                    let presentationContentType = contentTypes.filter { $0.contains(OpenXmlFormats.presentation.rawValue)  }
                    
                    
                    if !documentContentType.isEmpty {
                        pathExtension = OpenXmlFormats.word.fileExtension
                    }
                    if !sheetContentType.isEmpty {
                        pathExtension = OpenXmlFormats.sheet.fileExtension
                    }
                    if !presentationContentType.isEmpty {
                        pathExtension = OpenXmlFormats.presentation.fileExtension
                    }
                    
                    DefaultFileManager().removeItem(at: tmpFileURL)
                }
            }
            return pathExtension
            
        } catch {
            return nil
        }
    }
    
    func contents() -> Data? {
        do {
            let _ = self.startAccessingSecurityScopedResource()
            defer { self.stopAccessingSecurityScopedResource() }
            return try Data(contentsOf: self)
        } catch let error {
            debugLog(error)
        }
        return nil
    }
    
    func getPath() -> String {
        if #available(iOS 16.0, *) {
            return self.path(percentEncoded: false)
        } else {
            return self.path
        }
    }
    
    var directoryPath: String {
        return self.deletingLastPathComponent().relativePath
    }
    
    var directoryURL: URL {
        return self.deletingLastPathComponent()
    }
    
    nonisolated func trimMedia(newName: String,
                               startTime: Double,
                               endTime: Double) async throws -> URL {
        
        let asset = AVAsset(url: self)
        let startTime = CMTime(seconds: startTime, preferredTimescale: 600)
        let endTime = CMTime(seconds: endTime, preferredTimescale: 600)
        let duration = CMTimeSubtract(endTime, startTime)
        
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        
        let outputURL = createURL(name: "\(newName).\(self.pathExtension.lowercased())")
        exportSession?.outputURL = outputURL
        exportSession?.outputFileType = self.getAVFileType()
        exportSession?.timeRange = CMTimeRange(start: startTime, duration: duration)
        
        await exportSession?.export()
        
        if exportSession?.status == .completed {
            return outputURL
        } else {
            throw RuntimeError(LocalizableError.commonError.localized)
        }
    }
    
    func rotateVideo(by angle: Int, newName: String) async throws -> URL {
        let asset = AVAsset(url: self)
        let angle = angle.degreesToRadians
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            debugLog("No video track")
            throw RuntimeError(LocalizableError.commonError.localized)
        }
        
        let composition = AVMutableComposition()
        guard let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            debugLog("Failed to create composition video track")
            throw RuntimeError(LocalizableError.commonError.localized)
        }
        
        try compositionVideoTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: asset.duration),
            of: videoTrack,
            at: .zero
        )
        
        // Add audio if available
        if let audioTrack = asset.tracks(withMediaType: .audio).first,
           let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            try compositionAudioTrack.insertTimeRange(
                CMTimeRange(start: .zero, duration: asset.duration),
                of: audioTrack,
                at: .zero
            )
        }
        
        // Calculate rotation transform
        let originalTransform = videoTrack.preferredTransform
        let videoSize = videoTrack.naturalSize.applying(originalTransform)
        
        let absWidth = abs(videoSize.width)
        let absHeight = abs(videoSize.height)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        var rotationTransform: CGAffineTransform
        var renderSize: CGSize
        
        switch angle {
        case 0:
            rotationTransform = originalTransform
            renderSize = CGSize(width: absWidth, height: absHeight)
            
        case .pi / 2, -3 * .pi / 2:
            rotationTransform = originalTransform.concatenating(
                CGAffineTransform(translationX: absHeight, y: 0).rotated(by: angle)
            )
            renderSize = CGSize(width: absHeight, height: absWidth)
            
        case .pi, -.pi:
            rotationTransform = originalTransform.concatenating(
                CGAffineTransform(translationX: absWidth, y: absHeight).rotated(by: angle)
            )
            renderSize = CGSize(width: absWidth, height: absHeight)
            
        case 3 * .pi / 2, -.pi / 2:
            rotationTransform = originalTransform.concatenating(
                CGAffineTransform(translationX: 0, y: absWidth).rotated(by: angle)
            )
            renderSize = CGSize(width: absHeight, height: absWidth)
            
        default:
            debugLog("Unsupported angle: \(angle)")
            throw RuntimeError(LocalizableError.commonError.localized)
            
        }
        
        videoComposition.renderSize = renderSize
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        layerInstruction.setTransform(rotationTransform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        let outputURL = createURL(name: "\(newName).\(self.pathExtension.lowercased())")
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            debugLog("Failed to create export session")
            throw RuntimeError(LocalizableError.commonError.localized)
        }
        
        exportSession.videoComposition = videoComposition
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov
        exportSession.shouldOptimizeForNetworkUse = true
        
        await exportSession.export()
        
        switch exportSession.status {
        case .completed:
            return outputURL
        case .failed:
            debugLog("Export failed")
            throw RuntimeError(LocalizableError.commonError.localized)
            
        default:
            debugLog("Export incomplete")
            throw RuntimeError(LocalizableError.commonError.localized)
        }
    }
    
    func createURL(name: String) -> URL {
        return self.deletingLastPathComponent().appendingPathComponent(name)
    }
    
    func open() {
        UIApplication.shared.open(self, options: [:], completionHandler: nil)
    }
}
