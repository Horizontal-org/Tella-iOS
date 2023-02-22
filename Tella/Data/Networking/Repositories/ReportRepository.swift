//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class ReportRepository:NSObject, WebRepository {
    
//    static var shared : ReportRepository = ReportRepository()
    
//  var uploadService : UploadService  
    
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

        let api = API.putReportFile((file, self))
        
        guard let url = api.url else {
            return Fail(error: APIError.invalidURL)
                .eraseToAnyPublisher()
        }
        UploadService.shared.startDownload(endpoint: api, isOnBackground: file.uploadOnBackground)
        
        guard let progress =  UploadService.shared.activeDownloads[url] else {
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
            let api = API.putReportFile((file, self))
            UploadService.shared.pauseDownload(endpoint: api)
        }
    }
}

extension ReportRepository {
    enum API {
        case createReport((Report))
        case putReportFile((FileToUpload, URLSessionDelegate))
        case postReportFile((FileToUpload))
        case headReportFile((FileToUpload))
    }
}

extension ReportRepository.API: APIRequest {
    
    var token: String? {
        
        switch self {
        case .createReport((let report)):
            return report.server?.accessToken
            
        case .putReportFile((let file, _)), .postReportFile((let file)), .headReportFile((let file)):
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
            
        case .putReportFile((let file, _)), .postReportFile((let file)), .headReportFile((let file)):
            return file.serverURL
        }
    }
    
    var path: String {
        switch self {
        case .createReport:
            return "/report"
            
        case .putReportFile((let file,_)), .postReportFile((let file)), .headReportFile((let file)):
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
        case .putReportFile((let file, _)):
            
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
    
    var uploadsSession: URLSession? {
        switch self {
        case .putReportFile((let file, let delegate)):
            return URLSession(
                configuration: file.uploadOnBackground ? .background(withIdentifier: "org.wearehorizontal.tella") : .default,
                delegate: delegate,
                delegateQueue: nil)
        default:
            return nil
        }
    }
    
}
