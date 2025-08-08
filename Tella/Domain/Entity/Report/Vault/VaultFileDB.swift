//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import AVFoundation
import SwiftUI

class VaultFileDB : Codable, Hashable, ObservableObject {
    
    var id : String?
    var type : VaultFileType
    var thumbnail : Data?
    var name :  String
    var created : Date
    var duration: Double?
    var size : Int
    var mimeType : String?
    var width : Double?
    var height : Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case type = "c_type"
        case thumbnail = "c_thumbnail"
        case name = "c_name"
        case created = "c_created"
        case duration = "c_duration"
        case size = "c_size"
        case mimeType = "c_mime_type"
        case width = "c_width"
        case height = "c_height"
        
    }
    
    static func == (lhs: VaultFileDB, rhs: VaultFileDB) -> Bool {
        lhs.name == rhs.name &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
    
    init(id: String?,
         type: VaultFileType,
         thumbnail: Data?,
         name: String,
         duration: Double?,
         size: Int ,
         mimeType: String?,
         width: Double?,
         height: Double?) {
        
        self.id = id
        self.type = type
        self.thumbnail = thumbnail
        self.name = name
        self.duration = duration
        self.size = size
        self.mimeType = mimeType
        self.created = Date()
        self.width = width
        self.height = height
        
    }
    
    init(id: String = UUID().uuidString,
         type: VaultFileType,
         name: String) {
        self.id = id
        self.type = type
        self.name = name
        self.size = 0
        self.created = Date()
    }
    
    init(file: NearbySharingFile) {
        self.id = UUID().uuidString
        self.type = .file
        self.name = file.fileName ?? ""
        self.thumbnail = file.thumbnail
        self.size = file.size ?? 0
        self.mimeType = file.fileType
        self.created = Date()
    }

    init(vaultFile :VaultFile) {
        self.id = vaultFile.containerName
        self.type = vaultFile.type == .folder ? .directory : .file
        self.thumbnail = vaultFile.thumbnail
        self.name = vaultFile.fileName
        self.duration = vaultFile.duration
        self.size = vaultFile.size
        self.mimeType = vaultFile.fileExtension.mimeType()
        self.created = vaultFile.created
        if let width = vaultFile.resolution?.width {
            self.width = width
        }
        if let height = vaultFile.resolution?.height {
            self.height = height
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        let typeInt = try container.decode(Int.self, forKey: .type)
        type = VaultFileType(rawValue: typeInt) ?? .unknown
        
        thumbnail = try container.decode(Data.self, forKey: .thumbnail)
        name = try container.decode(String.self, forKey: .name)
        
        let createdDouble = try container.decode(Double.self, forKey: .created)
        created = createdDouble.getDate() ?? Date()
        
        duration = try container.decode(Double.self, forKey: .duration)
        size = try container.decode(Int.self, forKey: .size)
        
        mimeType = try container.decode(String.self, forKey: .mimeType)
        
        width = try container.decode(Double.self, forKey: .width)
        height = try container.decode(Double.self, forKey: .height)
        
        
    }
    
    init(dictionnary: [String:Any])   {
        
        let id = dictionnary[CodingKeys.id.rawValue] as? String
        
        let typeInt = dictionnary[CodingKeys.type.rawValue] as? Int
        let type = VaultFileType(rawValue: typeInt ?? 0) ?? .unknown
        
        
        let thumbnail = dictionnary[CodingKeys.thumbnail.rawValue] as? Data
        let name = dictionnary[CodingKeys.name.rawValue] as? String
        
        
        let createdDouble = dictionnary[CodingKeys.created.rawValue] as? Double
        let created = createdDouble?.getDate() ?? Date()
        
        
        let duration = dictionnary[CodingKeys.duration.rawValue] as? Double
        
        
        let size = dictionnary[CodingKeys.size.rawValue] as? Int
        let mimeType = dictionnary[CodingKeys.mimeType.rawValue] as? String
        
        let width = dictionnary[CodingKeys.width.rawValue] as? Double
        let height = dictionnary[CodingKeys.height.rawValue] as? Double
        
        
        
        
        self.id = id ?? ""
        self.type = type
        self.thumbnail = thumbnail
        self.name = name ?? ""
        self.created = created
        self.duration = duration
        self.size = size ?? 0
        self.mimeType = mimeType
        self.width = width
        self.height = height
        
        
    }
}

extension VaultFileDB: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "\(type): \(String(describing: name)), \(id)"
    }
    
}


extension VaultFileDB {
    
    var thumbnailImage: UIImage {
        
        guard let thumbnail else {return UIImage()}
        
        guard let image = UIImage(data: thumbnail) else {return UIImage()}
        
        return image
    }
    
    
    
    var iconImage: UIImage {
        
        switch type {
            
        case .directory:
            return #imageLiteral(resourceName: "filetype.small_folder")
            
        case .file:
            switch mimeType?.tellaFileType {
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
            
        case .unknown:
            return #imageLiteral(resourceName: "filetype.small_document")
            
        }
    }
    
    var bigIconImage: UIImage {
        
        switch type {
            
        case .directory:
            return #imageLiteral(resourceName: "filetype.big_folder")
            
        case .file:
            switch mimeType?.tellaFileType {
            case .audio:
                return #imageLiteral(resourceName: "filetype.big_audio")
            case .document:
                return #imageLiteral(resourceName: "filetype.big_document")
            case .video:
                return #imageLiteral(resourceName: "filetype.big_video")
            case .image:
                return UIImage()
            case .other:
                return #imageLiteral(resourceName: "filetype.big_document")
                
            default:
                return #imageLiteral(resourceName: "filetype.big_document")
            }
            
        case .unknown:
            return #imageLiteral(resourceName: "filetype.big_document")
        }
    }
}

extension VaultFileDB {
    
    var formattedCreationDate : String {
        get {
            return created.fileCreationDate()
        }
    }
}

extension VaultFileDB {
    
    var longFormattedCreationDate : String {
        get {
            return created.getFormattedDateString(format: DateFormat.fileInfo.rawValue)
        }
    }
}

extension VaultFileDB {
    
    var formattedResolution : String? {
        get {
            guard let width, let height  else {return nil}
            return "\(Int( width)):\(Int( height))"
        }
    }
}

extension VaultFileDB {
    
    var formattedDuration : String? {
        get {
            guard let duration = duration else {return nil}
            return  duration.shortTimeString()
        }
    }
    
    var tellaFileType: TellaFileType {
        get {
            return self.mimeType?.tellaFileType ?? .other
        }
    }
    
    var fileExtension: String {
        get {
            return self.mimeType?.getExtension() ?? ""
        }
    }
}


extension Array where Element == Dictionary<String,Any>{
      func getVaultFiles() -> [VaultFileDB] {
        return self.compactMap{VaultFileDB.init(dictionnary: $0)}
    }
}

extension VaultFileDB {
    func getCopyName(from vaultFilesManager: VaultFilesManager?) -> String {

        var baseName: String
        var copyNumber = 0
        
        // Check if the current name already has the "copy" suffix
        if name.hasSuffix(LocalizableVault.copy.localized) {
            baseName = name
        } else {
            baseName = name + LocalizableVault.copy.localized
        }
        
        // Generate the new filename and check if it exists
        var newFileName = baseName
        while vaultFilesManager?.vaultFileExists(name: newFileName) == true {
            copyNumber += 1
            newFileName = baseName + "-" + "\(copyNumber)"
        }
        return newFileName
    }
}
