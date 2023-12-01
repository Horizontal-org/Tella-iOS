//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class BackgroundActivityModel {
    
    var id: String
    var name: String
    var type: BackgroundActivityType = .file
    var mimeType: String
    var thumb: Data? = nil
    var status: BackgroundActivityStatus = .inProgress
    
    init(id: String, name: String, type: BackgroundActivityType, mimeType: String, thumb: Data? = nil, status: BackgroundActivityStatus) {
        self.id = id
        self.name = name
        self.type = type
        self.mimeType = mimeType
        self.thumb = thumb
        self.status = status
    }
}

extension BackgroundActivityModel {
    static func stub() -> BackgroundActivityModel {
        return BackgroundActivityModel(id: "1234", 
                                       name: "Uploading “Report 345”",
                                       type: .file,
                                       mimeType: "application/pdf",
                                       thumb: nil,
                                       status: .inProgress)
    }
}
