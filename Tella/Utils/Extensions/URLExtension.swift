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

