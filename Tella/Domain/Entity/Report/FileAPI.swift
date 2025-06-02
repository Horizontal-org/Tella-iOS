//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
 
