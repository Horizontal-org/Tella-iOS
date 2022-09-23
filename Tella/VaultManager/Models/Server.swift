//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class Server {
   
    var id : Int?
    var name : String
    var url : String
    var username : String
    var password : String

    init(id : Int? = nil,
         name : String,
         url : String,
         username : String,
         password : String) {
        
        self.id = id
        self.name = name
        self.url = url
        self.username = username
        self.password = password
    }
}
