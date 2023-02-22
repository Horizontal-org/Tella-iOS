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
