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
}

