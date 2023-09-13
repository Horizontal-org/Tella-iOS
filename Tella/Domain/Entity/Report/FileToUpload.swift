//
// Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

class FileToUpload {
    var id : String
    var idReport : String
    var fileUrlPath : URL
    var accessToken : String
    var serverURL : String
    var data : Data?
    var fileName : String
    var fileExtension : String
    var fileId : String?
    var fileSize : Int
    var bytesSent : Int
    var uploadOnBackground : Bool

    init(idReport: String, fileUrlPath: URL, accessToken: String, serverURL: String, data: Data?, fileName: String, fileExtension: String, fileId: String?, fileSize: Int, bytesSent:Int, uploadOnBackground : Bool = false) {
        self.id = UUID().uuidString
        self.idReport = idReport
        self.fileUrlPath = fileUrlPath
        self.accessToken = accessToken
        self.serverURL = serverURL
        self.data = data
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.fileId = fileId
        self.fileSize = fileSize
        self.bytesSent = bytesSent
        self.uploadOnBackground = uploadOnBackground
    }
}
