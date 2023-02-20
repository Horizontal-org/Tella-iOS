//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

class ProjectAPI: DomainModel {
    
    var id : String?
    var slug : String?
    var name : String?

    init(id: String?, slug: String?, name: String?) {
        self.id = id
        self.slug = slug
        self.name = name
    }
}
