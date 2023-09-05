//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class FileAPI: DomainModel {

    var id, fileName, bucket, type: String?
    var fileInfo: String?

    init(id: String?, fileName: String? ) {
        self.id = id
        self.fileName = fileName
    }
}
 
