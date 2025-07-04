//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

public class FileInfo {
    var url: URL
    var mimeType: String?
    var fileName: String?
    var name: String?
    var fileId : String?
    
    init(withFileURL url : URL, mimeType: String? = nil, fileName: String? = nil, name: String? = nil, fileId: String?) {
        self.url = url
        self.mimeType = mimeType
        self.fileName = fileName
        self.name = name
        self.fileId = fileId
    }
}
