//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class Server : Hashable {
    var id : Int?
    var name : String?
    var url : String?
    var username : String?
    var password : String?
    var accessToken : String?
    var activatedMetadata : Bool?
    var backgroundUpload : Bool?
    var projectId : String?
    var slug : String?
    var autoUpload: Bool?
    var autoDelete: Bool?
    var serverType: ServerConnectionType?

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
         autoUpload: Bool?,
         autoDelete: Bool ,
         serverType: ServerConnectionType? = nil
        ) {
        self.id = id
        self.name = name
        self.url = serverURL
        self.username = username
        self.password = password
        self.accessToken = accessToken
        self.activatedMetadata = activatedMetadata
        self.backgroundUpload = backgroundUpload
        self.projectId = projectId
        self.slug = slug
        self.autoUpload = autoUpload
        self.autoDelete = autoDelete
        self.serverType = serverType
    }
    
    init() {
        
    }
    
    static func == (lhs: Server, rhs: Server) -> Bool {
        lhs.id  == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id.hashValue)
    }
    private enum CodingKeys: String, CodingKey {
        case id, name, url, username, password, accessToken, activatedMetadata, backgroundUpload, projectId, slug, autoUpload, autoDelete, serverType
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        url = try container.decodeIfPresent(String.self, forKey: .url)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        activatedMetadata = try container.decodeIfPresent(Bool.self, forKey: .activatedMetadata)
        backgroundUpload = try container.decodeIfPresent(Bool.self, forKey: .backgroundUpload)
        projectId = try container.decodeIfPresent(String.self, forKey: .projectId)
        slug = try container.decodeIfPresent(String.self, forKey: .slug)
        autoUpload = try container.decodeIfPresent(Bool.self, forKey: .autoUpload)
        autoDelete = try container.decodeIfPresent(Bool.self, forKey: .autoDelete)
        serverType = try container.decodeIfPresent(ServerConnectionType.self, forKey: .serverType)
    }
    
}
