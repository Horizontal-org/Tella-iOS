//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class TellaServer : WebServer {

    /// Server version from which the file PUT endpoint and upload flow use v2  (e.g. "1.4.0"). All versions >= this use v2.
    static let fileAPIv2MinimumVersion = "1.4.0"

    var activatedMetadata : Bool?
    var backgroundUpload : Bool?
    var projectId : String?
    var slug : String?
    var autoUpload: Bool?
    var autoDelete: Bool?
    var accessToken: String?
    var version: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "c_server_id"
        case activatedMetadata = "c_activated_metadata"
        case backgroundUpload = "c_background_upload"
        case projectId = "c_api_project_id"
        case slug = "c_slug"
        case autoUpload = "c_auto_upload"
        case autoDelete = "c_auto_delete"
        case accessToken = "c_access_token"
        case version = "c_version"
    }
    
    init(id: Int? = nil,
         name: String? = nil,
         serverURL: String? = nil,
         username: String? = nil,
         password: String? = nil,
         accessToken: String? = nil,
         activatedMetadata: Bool? = nil,
         backgroundUpload: Bool? = nil,
         projectId: String? = nil,
         slug: String? = nil,
         autoUpload: Bool,
         autoDelete: Bool,
         serverType: ServerConnectionType? = .tella,
         version: String? = nil) {
        
        self.activatedMetadata = activatedMetadata
        self.backgroundUpload = backgroundUpload
        self.projectId = projectId
        self.slug = slug
        self.autoUpload = autoUpload
        self.autoDelete = autoDelete
        self.accessToken = accessToken
        self.version = version
        
        super.init(id: id,
                   name: name,
                   serverURL: serverURL,
                   username: username,
                   password: password,
                   serverType: serverType)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
