//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import MobileCoreServices
import UniformTypeIdentifiers


extension String {
    func getDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dataBase.rawValue
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.date(from: self) // replace Date String
    }
    
    func getBaseURL() -> String? {
        let url = NSURL(string: self)
        return "https://" + (url?.host ?? "")
    }
    
    func getFileSizeWithoutUnit() -> String {
        let array =  self.getStringComponents(separator: " ")
        guard !array.isEmpty else {return ""}
        return array[0]
    }
    
    func getStringComponents(separator: String) -> [String] {
        return self.components(separatedBy: separator)
    }
    
    var fileType: TellaFileType {
        
        let fileType: TellaFileType
        
        switch self.lowercased() {
            
        case "gif", "jpeg", "jpg", "png", "tif", "tiff", "wbmp", "ico", "jng", "bmp", "svg", "svgz", "webp", "heic", "heif" :
            fileType = .image
            
        case "hevc", "3gpp", "3gp", "ts", "mp4", "mpeg", "mpg", "mov", "webm", "flv", "m4v", "mng", "asx", "asf", "wmv", "avi", "wma":
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
    
    func getRecoveredFileName() -> String {
        
        var fileType = ""
        
        switch self.fileType {
        case .image:
            fileType = "image"
        case .video:
            fileType = "video"
        case .audio:
            fileType = "audio"
        case .document:
            fileType = "document"
        default:
            fileType = "file"
        }
        
        return "\(fileType)-\(Date().getDate())"
    }

//    func getMimeType() -> String {
//
//        let unknown = "application/octet-stream"
//
//        guard let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, self as CFString, nil) else {
//            return  unknown
//        }
//
//        guard let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI.takeUnretainedValue(), kUTTagClassMIMEType) else {
//            return  unknown
//        }
//
//        return String(mimeUTI.takeUnretainedValue())
//    }
    

    
}

extension String {

    func mimeType() -> String {
         if let type = UTType(filenameExtension: self) {
            if let mimetype = type.preferredMIMEType {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }

    var containsImage: Bool {
        if let type = UTType(mimeType: self) {
            return type.conforms(to: .image)
        }
        return false
    }
    
    var containsAudio: Bool {
        if let type = UTType(mimeType: self) {
            return type.conforms(to: .audio)
        }
        return false
    }
    
    var containsMovie: Bool {
        if let type = UTType(mimeType: self) {
            return type.conforms(to: .movie)   // ex. .mp4-movies
        }
        return false
    }
    
    var containsVideo: Bool {
        if let type = UTType(mimeType: self) {
            return type.conforms(to: .video)
        }
        return false
    }
}

