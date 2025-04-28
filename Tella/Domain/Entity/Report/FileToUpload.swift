//
// Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class FileToUpload {
    var id : String
    var idReport : String
    var fileUrlPath : URL
    var accessToken : String
    var serverURL : String
    var fileName : String
    var fileExtension : String
    var fileId : String?
    var fileSize : Int
    var bytesSent : Int
    var uploadOnBackground : Bool

    init(idReport: String, fileUrlPath: URL, accessToken: String, serverURL: String, fileName: String, fileExtension: String, fileId: String?, fileSize: Int, bytesSent:Int, uploadOnBackground : Bool = false) {
        self.id = UUID().uuidString
        self.idReport = idReport
        self.fileUrlPath = fileUrlPath
        self.accessToken = accessToken
        self.serverURL = serverURL
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.fileId = fileId
        self.fileSize = fileSize
        self.bytesSent = bytesSent
        self.uploadOnBackground = uploadOnBackground
    }
}
