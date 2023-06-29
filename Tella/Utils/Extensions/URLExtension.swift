//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//


import AVFoundation
import UIKit
import QuickLook

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
    
    
    var fileType: FileType {
        
        let fileType: FileType
        
        switch self.pathExtension.lowercased() {
            
        case "gif", "jpeg", "jpg", "png", "tif", "tiff", "wbmp", "ico", "jng", "bmp", "svg", "svgz", "webp", "heic" :
            fileType = .image
            
        case "3gpp", "3gp", "ts", "mp4", "mpeg", "mpg", "mov", "webm", "flv", "m4v", "mng", "asx", "asf", "wmv", "avi":
            fileType = .video
            
        case "mid", "midi", "kar", "mp3", "ogg", "m4a", "ra":
            fileType = .audio
            
        case "txt", "doc", "pdf", "rtf", "xls", "ppt", "docx", "xlsx", "pptx":
            fileType = .document
            
        default:
            fileType = .other
        }
        return fileType
    }

    func thumbnail() async -> Data? {
        let resolutionForImage = resolutionForImage()
        
        let width = CGFloat( resolutionForImage?.width ?? 350)
        let height = CGFloat( resolutionForImage?.height ?? 350)

        let aspectRatio = width/height

        let thumbnailSize = CGSize(width: 350, height: 350*aspectRatio)
        
        let thumbnail: UIImage?
        do {
            thumbnail = try await getThumbnail(for: self, size: thumbnailSize, scale: UIScreen.screenScale)
        }catch {
            thumbnail = nil
        }
        return thumbnail?.pngData()
        
    }

    func generateVideoThumbnail() -> UIImage? {
        do {
            let asset = AVURLAsset(url: self)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let cgImage = try imageGenerator.copyCGImage(at: .zero,
                                                         actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch let error {
            debugLog(error)
            return nil
        }
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
    func exportFile(destinationURL: URL) async -> URL? {
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
}

