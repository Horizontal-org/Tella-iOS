//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation


class Report {
    
    var id : String
    var title : String
    var description : String
    var date : String
    var status : String

    init(id : String,
         title : String,
         description : String,
         date : String,
         status : String) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.status = status
    }
}
