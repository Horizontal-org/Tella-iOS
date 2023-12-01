//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation


class BackgroundActivitiesViewModel:ObservableObject {
    
    @Published var items : [BackgroundActivityModel] = []
    
    init() {
        items = [BackgroundActivityModel(id: "1234",
                                         name: "Encrypting “Interview recording”",
                                         type: .file,
                                         mimeType: "audio/x-m4a",
                                         thumb: nil,
                                         status: .inProgress),
                 BackgroundActivityModel(id: "4354",
                                         name: "Encrypting “IMG1021_6a.jpg” ",
                                         type: .file,
                                         mimeType: "image/png",
                                         thumb: nil,
                                         status: .inProgress),
                 BackgroundActivityModel(id: "7676",
                                         name: "Uploading “Report 345”",
                                         type: .file,
                                         mimeType: "application/pdf",
                                         thumb: nil,
                                         status: .inProgress)]
    }
}


