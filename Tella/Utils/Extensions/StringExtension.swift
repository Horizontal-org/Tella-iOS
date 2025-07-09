//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import MobileCoreServices
import UniformTypeIdentifiers
import UIKit
import Network

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
    
    func slash() -> String {
        return self.hasSuffix("/") ? self : self + "/"
    }
    
    func preffixedSlash() -> String {
        return self.hasPrefix("/") ? self : "/" + self
    }
}

extension String {

    func mimeType() -> String? {
         if let type = UTType(filenameExtension: self) {
            if let mimetype = type.preferredMIMEType {
                return mimetype as String
            }
        }
        return nil
    }
    
    func getExtension() -> String {
        
        let unmanagedFileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, self as CFString, nil)?.takeRetainedValue()
       guard let fileExtension = UTTypeCopyPreferredTagWithClass((unmanagedFileUTI)!, kUTTagClassFilenameExtension)?.takeRetainedValue()
        else { return ""}
        
        return fileExtension as String
    }

    
    
    var tellaFileType: TellaFileType {

        guard let type = UTType(mimeType: self) else {
            return .other
        }
        
        switch type {
        case _ where type.conforms(to: .video) || type.conforms(to: .movie):
            return .video
        case _ where type.conforms(to: .image):
            return .image
        case _ where type.conforms(to: .audio):
            return .audio
        case _ where type.conforms(to: .pdf) || type.conforms(to: .presentation) || type.conforms(to: .spreadsheet):
            return .document
        default:
            return .other
        }
    }
    
    var smallIconImage: UIImage {
        switch self.tellaFileType {
        case .audio:
            return #imageLiteral(resourceName: "filetype.small_audio")
        case .document:
            return #imageLiteral(resourceName: "filetype.small_document")
        case .video:
            return #imageLiteral(resourceName: "filetype.small_video")
        case .image:
            return UIImage()
        case .other:
            return #imageLiteral(resourceName: "filetype.small_document")
            
        default:
            return #imageLiteral(resourceName: "filetype.small_document")
        }
    }
    
    var isPDF: Bool {

        guard let type = UTType(mimeType: self) else {
            return false
        }

        return type.conforms(to: .pdf)
    }
}


extension String {
    var dictionnary: [String:Any] {
        
        guard let data = self.data(using: .utf8) else { return [:]}
        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String,Any> else { return [:]}
            return jsonArray
        } catch let error as NSError {
            debugLog(error)
            return [:]
        }
    }
    
    var arraydDictionnary: [[String:Any]] {
        
        guard let data = self.data(using: .utf8) else { return [[:]]}
        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [Dictionary<String,Any>] else { return[ [:]]}
            return jsonArray
        } catch let error as NSError {
            debugLog(error)
            return [[:]]
        }
    }

    
    func decode<T: Codable>(_ type: T.Type) throws -> T {
        let data = try? JSONSerialization.data(withJSONObject: self)
        return try JSONDecoder().decode (type, from: data)
    }
    
    func decodeJSON<T: Codable>(_ type: T.Type)  -> T? {
        do {
            guard let data = self.data(using: .utf8) else {
                throw NSError(domain: "StringDecodeError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot convert string to Data"])
            }
            return try JSONDecoder().decode(type, from: data)
        }
        catch let error as NSError {
            debugLog(error)
            return nil
        }
    }

    func convertIPAddressToBytes() throws -> [UInt8] {
        if let ipv4 = IPv4Address(self) {
            return Array(ipv4.rawValue)
        } else if let ipv6 = IPv6Address(self) {
            return Array(ipv6.rawValue)
        } else {
            throw CertificateError.invalidIPAddress
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

extension String {
    func url() -> URL? {
        return URL(string: self)
    }

    func asFileURL() -> URL? {
        guard !self.isEmpty else { return nil }
        return URL(fileURLWithPath: self)
    }

    
    var addline: String {
        return self + "\n"
    }
    
    var addTwolines: String {
        return self + "\n\n"
    }

}


enum CertificateError: Error {
    case invalidIPAddress
}

extension String {
    func formatHash() -> String {
        let trimmed = String(self.prefix(64))
        let chunks = self.chunked(into: 4)
        let lines = chunks.chunked(into: 4)
        return lines.map { $0.joined(separator: " ") }.joined(separator: "\n")
    }
    
    // Chunk String into substrings of fixed size
    func chunked(into size: Int) -> [String] {
        var result: [String] = []
        var start = startIndex
        while start < endIndex {
            let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
            result.append(String(self[start..<end]))
            start = end
        }
        return result
    }
}
