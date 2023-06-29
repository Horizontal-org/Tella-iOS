//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

public class FileInfo {
    var url: URL
    var mimeType: String?
    var fileName: String?
    var name: String?
    var data: Data?
    var fileId : String?
    
    init(withFileURL url : URL, mimeType: String? = nil, fileName: String? = nil, name: String? = nil, data: Data? = nil, fileId: String?) {
        self.url = url
        self.mimeType = mimeType
        self.fileName = fileName
        self.name = name
        self.data = data
        self.fileId = fileId
    }
}
