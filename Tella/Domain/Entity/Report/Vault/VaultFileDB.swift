//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


class VaultFileDB : Codable, Hashable {
    
    var id : String?
    var type : VaultFileType
    var hash : String?
    var metadata : String?
    var thumbnail : Data?
    var name :  String?
    var created : Date?
    var duration: Double?
    var anonymous : Bool
    var size : Int?
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
        created = createdDouble.getDate()
        
        duration = try container.decode(Double.self, forKey: .duration)
        anonymous = try container.decode(Bool.self, forKey: .anonymous)
        size = try container.decode(Int.self, forKey: .size)
        
        mimeType = try container.decode(String.self, forKey: .mimeType)
    }
}

