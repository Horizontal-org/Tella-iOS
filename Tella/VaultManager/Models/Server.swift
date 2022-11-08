//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class Server : Hashable{
    
   
    var id : Int?
    var name : String?
    var url : String?
    var username : String?
    var password : String?
    var accessToken : String?
    var activatedMetadata : Bool?
    var backgroundUpload : Bool?  

    init(id : Int? = nil,
         name : String?,
         url : String?,
         username : String?,
         password : String?,
         accessToken : String?,
         activatedMetadata : Bool?,
         backgroundUpload : Bool?) {
        
        self.id = id
        self.name = name
        self.url = url
        self.username = username
        self.password = password
        self.accessToken = accessToken
        self.activatedMetadata = activatedMetadata
        self.backgroundUpload = backgroundUpload
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




