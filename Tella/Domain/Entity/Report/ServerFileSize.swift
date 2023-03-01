//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation

class ServerFileSize: DomainModel {
    
    var size : Int?

    init(size: String?) {
        self.size = Int(size ?? "0")
    }
}


class BoolModel: DomainModel {
    
    var success : Bool?

    init(success: Bool?) {
        self.success = success
    }
}
