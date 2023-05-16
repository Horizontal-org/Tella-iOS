//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class ReportRepository:NSObject, WebRepository {
    
    func sendReport(report:Report,mainAppModel: MainAppModel) -> CurrentValueSubject<UploadResponse?,APIError> {
      return  UploadService.shared.addUploadReportOperation(report: report, mainAppModel: mainAppModel)
    }

    func pause(reportId : Int?) {
        UploadService.shared.pauseDownload(reportId: reportId)
    }
    
    func checkUploadReportOperation(reportId : Int?) -> CurrentValueSubject<UploadResponse?,APIError>? {
        UploadService.shared.checkUploadReportOperation(reportId: reportId)
    }
    
}


extension ReportRepository {
    enum API {
        case createReport((Report))
        case putReportFile((FileToUpload))
        case postReportFile((FileToUpload))
        case headReportFile((FileToUpload))

    }
}

extension ReportRepository.API: APIRequest {
    
    var token: String? {
        
        switch self {
        case .createReport((let report)):
            return report.server?.accessToken
            
        case .putReportFile((let file)), .postReportFile((let file)), .headReportFile((let file)):
            return file.accessToken
        }
    }
    
    var keyValues: [Key : Value?]? {
        
        switch self {

        case .createReport((let report)):
            return [
                "title": report.title,
                "description": report.description,
                // "deviceInfo": {},
                "projectId": report.server?.projectId
            ]

        default:
            return nil
        }
    }
    
    var baseURL: String {
        switch self {

        case .createReport((let report)):
            return report.server?.url ?? ""
            
        case .putReportFile((let file)), .postReportFile((let file)), .headReportFile((let file)):
            return file.serverURL

        }
    }
    
    var path: String {
        switch self {
            
        case .createReport:
            return "/report"
            
        case .putReportFile((let file)), .postReportFile((let file)), .headReportFile((let file)):
            return "/file/\(file.idReport)/\(file.fileUrlPath.lastPathComponent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)"

            
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            
        case .putReportFile:
            return HTTPMethod.put
            
        case .postReportFile(_), .createReport(_):
            return HTTPMethod.post
            
        case .headReportFile(_):
            return HTTPMethod.head

        }
    }
    
    var fileToUpload: FileInfo? {
        
        switch self {
        case .putReportFile((let file)):
            
            let mimeType = MIMEType.mime(for: file.fileExtension)
            return FileInfo(withFileURL: file.fileUrlPath, mimeType:mimeType , fileName: "name", name: file.fileName , data: file.data, fileId: file.fileId)

        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .putReportFile((_)):
            return [HTTPHeaderField.contentType.rawValue : ContentType.data.rawValue]

        default:
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        }
    }
}
