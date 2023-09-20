//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftUI

class VaultFileDB : Codable, Hashable, ObservableObject {
    
    var id : String
    var type : VaultFileType
    var hash : String?
    var metadata : String?
    var thumbnail : Data?
    var name :  String
    var created : Date
    var duration: Double?
    var anonymous : Bool = true
    var size : Int
    var mimeType : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_id"
        case type = "c_type"
        case hash = "c_hash"
        case metadata = "c_metadata"
        case thumbnail = "c_thumbnail"
        case name = "c_name"
        case created = "c_created"
        case duration = "c_duration"
        case anonymous = "c_anonymous"
        case size = "c_size"
        case mimeType = "c_mime_type"
    }
    
    static func == (lhs: VaultFileDB, rhs: VaultFileDB) -> Bool {
        lhs.name == rhs.name &&
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
    
    init(id: String = UUID().uuidString,
         type: VaultFileType,
         hash: String?  ,
         metadata: String?,
         thumbnail: Data?,
         name: String,
         duration: Double?,
         anonymous: Bool,
         size: Int ,
         mimeType: String? ) {
        
        self.id = id
        self.type = type
        self.hash = hash
        self.metadata = metadata
        self.thumbnail = thumbnail
        self.name = name
        self.duration = duration
        self.anonymous = anonymous
        self.size = size
        self.mimeType = mimeType
        self.created = Date()
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        let typeInt = try container.decode(Int.self, forKey: .type)
        type = VaultFileType(rawValue: typeInt) ?? .unknown
        
        hash = try container.decode(String.self, forKey: .hash)
        metadata = try container.decode(String.self, forKey: .metadata)
        thumbnail = try container.decode(Data.self, forKey: .thumbnail)
        name = try container.decode(String.self, forKey: .name)
        
        let createdDouble = try container.decode(Double.self, forKey: .created)
        created = createdDouble.getDate() ?? Date()
        
        duration = try container.decode(Double.self, forKey: .duration)
        anonymous = try container.decode(Bool.self, forKey: .anonymous)
        size = try container.decode(Int.self, forKey: .size)
        
        mimeType = try container.decode(String.self, forKey: .mimeType)
    }
    
     init(dictionnary: [String:Any])   {

       let id = dictionnary[CodingKeys.id.rawValue] as? String
       
       let typeInt = dictionnary[CodingKeys.type.rawValue] as? Int
       let type = VaultFileType(rawValue: typeInt ?? 0) ?? .unknown
       
       
       let hash = dictionnary[CodingKeys.hash.rawValue] as? String
       let metadata = dictionnary[CodingKeys.metadata.rawValue] as? String
       let thumbnail = dictionnary[CodingKeys.thumbnail.rawValue] as? Data
       let name = dictionnary[CodingKeys.name.rawValue] as? String

       
       let createdDouble = dictionnary[CodingKeys.created.rawValue] as? Double
        let created = createdDouble?.getDate() ?? Date()
       
       
       let duration = dictionnary[CodingKeys.duration.rawValue] as? Double
       let anonymous = dictionnary[CodingKeys.anonymous.rawValue] as? Bool

       
       let size = dictionnary[CodingKeys.size.rawValue] as? Int
       let mimeType = dictionnary[CodingKeys.mimeType.rawValue] as? String


//       return  VaultFileDB(id:id ?? "",
//                           type: type,
//                           hash: hash,
//                           metadata: metadata,
//                           thumbnail: thumbnail,
//                           name: name ?? "",
//                           duration: duration,
//                           anonymous: anonymous ?? true,
//                           size: size ?? 0,
//                           mimeType: mimeType)
         
         
         self.id = id ?? ""
         self.type = type
         self.hash = hash
         self.metadata =  metadata
         self.thumbnail = thumbnail
         self.name = name ?? ""
         self.created = created
         self.duration = duration
         self.anonymous = anonymous ?? true
         self.size = size ?? 0
         self.mimeType = mimeType

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
            return ""
            //TODO: Dhekra
//            guard let resolution = resolution else {return nil}
//            return "\(Int(resolution.width)):\(Int(resolution.height))"
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


//class VaultFileViewModel: ObservableObject {
//
//    var id : String
//    var thumbnail : UIImage
//    var name :  String
//    var duration: String?
//    var size : Int?
//    var fileType : TellaFileType?
//    var resolution: String?
//    var formattedCreationDate : String
//    var longFormattedCreationDate : String
//
//    var iconImage: UIImage
//    var bigIconImage: UIImage
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id.hashValue)
//    }
//
//    init(vaulFileDB: VaultFileDB) {
//        self.id = vaulFileDB.id
//        self.thumbnail = vaulFileDB.thumbnailImage
//        self.name = vaulFileDB.name
//        self.duration = vaulFileDB.duration?.shortTimeString()
//        size = vaulFileDB.size
//
//        self.fileType = vaulFileDB.mimeType?.tellaFileType
//
//        self.resolution = "" //TODO: Dhekra
////        guard let resolution = resolution else {return nil}
////        return "\(Int(resolution.width)):\(Int(resolution.height))"
//
//
//        self.formattedCreationDate = vaulFileDB.created?.fileCreationDate() ?? ""
//        self.longFormattedCreationDate = vaulFileDB.created?.getFormattedDateString(format: DateFormat.fileInfo.rawValue) ?? ""
//
//        self.iconImage = vaulFileDB.iconImage
//        self.bigIconImage = vaulFileDB.bigIconImage
//
//    }
//
//
//}
