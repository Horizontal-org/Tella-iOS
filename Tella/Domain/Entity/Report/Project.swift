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

    init(id: Int? = nil,
         name: String? = nil,
         serverURL: String? = nil,
         username: String? = nil,
         password: String? = nil,
         accessToken: String? = nil,
         activatedMetadata: Bool? = nil,
         backgroundUpload: Bool? = nil,
         projectId: String? = nil,
         slug: String? = nil) {
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
    }
    
    init() {
        
    }
    
    static func == (lhs: Server, rhs: Server) -> Bool {
        lhs.id  == rhs.id
    }

    func hash(into hasher: inout Hasher){
        hasher.combine(id.hashValue)
    }

}
