//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class ReportRepository: WebRepository {
    
    // MARK: - Report API (create report & head file)
    
    /// Creates a report on the server and returns the domain model (ReportAPI) with response headers.
    func createReport(report: Report) -> AnyPublisher<ReportAPI, APIError> {
        let endpoint = ReportRepository.API.createReport(report)
        return (getAPIResponse(endpoint: endpoint) as APIResponse<SubmitReportResult>)
            .compactMap { dto, headers -> ReportAPI? in
                guard let api = dto.toDomain() as? ReportAPI else { return nil }
                return api
            }
            .eraseToAnyPublisher()
    }
    
    /// Checks file size on server via HEAD request.
    func headReportFile(fileToUpload: FileToUpload) -> AnyPublisher<Int, APIError> {
        let endpoint = ReportRepository.API.headReportFile(fileToUpload)
        return (getAPIResponse(endpoint: endpoint) as APIResponse<EmptyResult>)
            .compactMap { _, headers -> Int? in
                guard let sizeValue = headers?["size"],
                      let sizeString = sizeValue as? String,
                      let size = Int(sizeString) else { return nil }
                return size
            }
            .eraseToAnyPublisher()
    }
    
    func makePutReportFileUploadTask(
        fileToUpload: FileToUpload,
        session: URLSession
    ) throws -> URLSessionUploadTask {
        
        let api = ReportRepository.API.putReportFile(fileToUpload)
        
        let fileURL = fileToUpload.fileUrlPath
        
        let _ = fileURL.startAccessingSecurityScopedResource()
        defer { fileURL.stopAccessingSecurityScopedResource() }
        
        let (_, task) = try makeUploadRequestAndTask(
            endpoint: api,
            fileURL: fileURL,
            session: session
        )
        
        return task
    }
}

extension ReportRepository {
    enum API {
        case createReport((Report))
        case headReportFile((FileToUpload))
        case putReportFile((FileToUpload))
    }
}

extension ReportRepository.API: APIRequest {
    
    var token: String? {
        
        switch self {
        case .createReport((let report)):
            return report.server?.accessToken
            
        case .putReportFile((let file)), .headReportFile((let file)):
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
            
        case .putReportFile((let file)), .headReportFile((let file)):
            return file.serverURL
        }
    }
    
    var path: String {
        switch self {
            
        case .createReport(let report):
            let projectId = report.server?.projectId ?? ""
            return "/project/\(projectId)"
            
        case .putReportFile((let file)), .headReportFile((let file)):
            return "/file/\(file.idReport)/\(file.fileName).\(file.fileExtension)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
            
        case .createReport(_):
            return HTTPMethod.post
            
        case .headReportFile(_):
            return HTTPMethod.head
            
        case .putReportFile:
            return HTTPMethod.put
        }
    }
    
    var fileToUpload: FileInfo? {
        
        switch self {
        case .putReportFile(let file):
            
            let mimeType = MIMEType.mime(for: file.fileExtension)
            return FileInfo(withFileURL: file.fileUrlPath, mimeType:mimeType , fileName: "name", name: file.fileName, fileId: file.fileId)
            
        default:
            return nil
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .putReportFile(let file):
            
            var header : [String:String] = [HTTPHeaderField.contentLength.rawValue :String(file.fileSize)]
            
            if let mimeType = file.fileExtension.mimeType() {
                header[HTTPHeaderField.contentType.rawValue] = mimeType
            }
            return header
            
        default:
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        }
    }
}
