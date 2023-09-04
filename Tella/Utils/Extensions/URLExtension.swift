//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//


import AVFoundation
import UIKit
import QuickLook
import ZIPFoundation

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
    
    /// This function take the url of the video from the parameter converts it into AVAsset and exports the video file after removing the metadata to the destination URL and send the destination URL back .
    /// If there is any issue it will return nil
    /// - Parameters:
    ///   - destinationURL: The URL where the file without the metadata is saved
    /// - Returns: The URL in which the file is saved or if there is any issue then it will return nil
    func returnVideoURLWithoutMetadata(destinationURL: URL) async -> URL? {
        let asset = AVAsset(url: self)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return nil }
        exportSession.outputURL = destinationURL
        exportSession.outputFileType =  self.getAVFileType()
        exportSession.metadata = nil
        exportSession.metadataItemFilter = .forSharing()
        await exportSession.export()
        if exportSession.status == .completed {
            return destinationURL
        } else {
            return nil
        }
    }
    func getAVFileType() -> AVFileType {
        switch self.pathExtension.lowercased() {
        case "mp4":
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
}

import UniformTypeIdentifiers

extension URL {
    
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let type = UTType(filenameExtension: pathExtension) {
            if let mimetype = type.preferredMIMEType {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    var containsImage: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .image)
        }
        return false
    }
    
    var containsAudio: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .audio)
        }
        return false
    }
    
    var containsMovie: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .movie)   // ex. .mp4-movies
        }
        return false
    }
    
    var containsVideo: Bool {
        let mimeType = self.mimeType()
        if let type = UTType(mimeType: mimeType) {
            return type.conforms(to: .video)
        }
        return false
    }
}
