//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class ReportRepository:NSObject, WebRepository {
    
    static var shared : ReportRepository = ReportRepository()
    
    lazy var uploadService : UploadService = UploadService(uploadsSession: URLSession(
        configuration: .background(withIdentifier: "org.wearehorizontal.tella"),
        delegate: self,
        delegateQueue: nil))
    
    func createReport(report:Report) -> AnyPublisher<ReportAPI, APIError> {
        
        let call : AnyPublisher<SubmitReportResult, APIError> = call(endpoint: API.createReport((report)))
        
        return call
            .compactMap{$0.toDomain() as? ReportAPI }
            .eraseToAnyPublisher()
    }
    
    func checkFileSizeOnServer(file:FileToUpload) -> AnyPublisher<(SizeResult?), APIError> {
        
        let call : AnyPublisher<(SizeResult?), APIError> = call(endpoint: API.headReportFile((file)))
        
        return call
    }
    
    func putReport(file:FileToUpload) -> AnyPublisher<UploadResponse, APIError> {
        
        
        let api = API.putReportFile((file))
        
        guard let url = api.url else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        uploadService.startDownload(endpoint: api)
        
        guard let progress =  uploadService.activeDownloads[url] else {
            return Fail(error: APIError.invalidURL) // to fix the error
                .eraseToAnyPublisher()
        }
        
        return progress
            .eraseToAnyPublisher()
    }
    
    func postReport(file:FileToUpload) -> AnyPublisher<(BoolResponse?), APIError> {
        
        let call : AnyPublisher<(BoolResponse?), APIError> = call(endpoint: API.postReportFile((file)))
        return call
    }
    
    func pause(_ filesToUpload: [FileToUpload]) {
        
        filesToUpload.forEach { file in
            let api = API.putReportFile((file))
            uploadService.pauseDownload(endpoint: api)
        }
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
