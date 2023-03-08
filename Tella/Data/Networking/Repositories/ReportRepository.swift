//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class ReportRepository:NSObject, WebRepository {
    
    func createReport(report:Report) -> AnyPublisher<APIResponse<ReportAPI>, APIError> {
        
        let api = API.createReport((report, self))
        let taskResponse = getTaskResponse(api: api, isOnBackground: report.server?.backgroundUpload ?? false)
        
        let call : AnyPublisher<(APIResponse<SubmitReportResult>, APIResponse<ReportAPI>), APIError>  = taskResponse.getAPIResponse()
        
        return call
            .tryMap{$0.1}
            .mapError{ _ in APIError.unexpectedResponse }
            .eraseToAnyPublisher()
    }
    
    
    func checkFileSizeOnServer(file:FileToUpload) -> AnyPublisher<APIResponse<ServerFileSize>, APIError> {
        
        let api = API.headReportFile((file, self))
        let taskResponse = getTaskResponse(api: api, isOnBackground: file.uploadOnBackground)
        
        let call : AnyPublisher<(APIResponse<SizeResult>, APIResponse<ServerFileSize>), APIError>  = taskResponse.getAPIResponse()
        
        return call
            .tryMap{$0.1}
            .mapError{ _ in APIError.unexpectedResponse }
            .eraseToAnyPublisher()
    }
    
    func putReport(file:FileToUpload) -> AnyPublisher<UploadResponse, APIError> {
        
        let api = API.putReportFile((file, self))
        let task =  UploadService.shared.startDownload(endpoint: api, isOnBackground: file.uploadOnBackground)
        
        guard let progress = UploadService.shared.activeTasks[task!] else {
            return Fail(error: APIError.invalidURL) // to fix the error
                .eraseToAnyPublisher()
        }
        
        return progress
            .eraseToAnyPublisher()
    }
    
    func postReport(file:FileToUpload) -> AnyPublisher<APIResponse<(BoolModel)>, APIError> {
        
        let api = API.postReportFile((file, self))
        let taskResponse = getTaskResponse(api: api, isOnBackground: file.uploadOnBackground)
        
        let call : AnyPublisher<(APIResponse<BoolResponse>, APIResponse<BoolModel>), APIError>  = taskResponse.getAPIResponse()
        
        return call
            .tryMap{$0.1}
            .mapError{ _ in APIError.unexpectedResponse }
            .eraseToAnyPublisher()
    }
    
    func pause(_ filesToUpload: [FileToUpload]) {
        
        filesToUpload.forEach { file in
            let api = API.putReportFile((file, self))
            UploadService.shared.pauseDownload(endpoint: api)
        }
    }
    
    func getTaskResponse(api:ReportRepository.API, isOnBackground:Bool) -> AnyPublisher<UploadResponse, APIError> {
        guard let task =  UploadService.shared.call(endpoint: api, isOnBackground: isOnBackground),
              let data : CurrentValueSubject<UploadResponse, APIError> =  UploadService.shared.activeTasks[task] else {
            return Fail<UploadResponse, APIError>(error: APIError.unexpectedResponse) // to fix the error
                .eraseToAnyPublisher()
        }
        return data
            .mapError{ _ in APIError.unexpectedResponse }
            .eraseToAnyPublisher()
    }
    
}

extension Publisher where Output == UploadResponse,
                          Failure == APIError {
    func getAPIResponse<Value1, Value2> () -> AnyPublisher<(APIResponse<Value1>, APIResponse<Value2>), APIError> where Value1: DataModel, Value2: DomainModel {
        return  self.tryMap { result in
            
            switch  result {
                
            case .response(let output):
                
                guard let output else { throw APIError.unexpectedResponse}
                guard let code = (output.response as? HTTPURLResponse)?.statusCode else {
                    throw APIError.unexpectedResponse
                }
                guard HTTPCodes.success.contains(code) else {
                    debugLog("Error code: \(code)")
                    throw APIError.httpCode(code)
                }
                
                if let size = (output.response as? HTTPURLResponse)?.allHeaderFields.filter({($0.key as? String) == "size"}),
                   !size.isEmpty   {
                    
                    if let jsonString = JSONStringEncoder().encode(size as! [String:Any]) {
                        let result : Value1 = try jsonString.decoded()
                        let dtoResponse  =  APIResponse.response(response: result)
                        let domainResponse  =  APIResponse.response(response: (result.toDomain() as? Value2))
                        
                        return (dtoResponse,domainResponse)
                    }
                }
                guard let data = output.data else {
                    throw APIError.unexpectedResponse
                }
                
                
                let dataString = String(decoding:  data  , as: UTF8.self)
                debugLog("Result:\(dataString)")
                
                let result : Value1 = try data.decoded()
                let dtoResponse  =  APIResponse.response(response: result)
                let domainResponse  =  APIResponse.response(response: (result.toDomain() as? Value2))

                return (dtoResponse,domainResponse)
                
            default:
                return (APIResponse.initial, APIResponse.initial)
            }
        }
        .mapError{ _ in APIError.unexpectedResponse }
        .eraseToAnyPublisher()
    }
}

extension ReportRepository {
    enum API {
        case createReport((Report, URLSessionDelegate))
        case putReportFile((FileToUpload, URLSessionDelegate))
        case postReportFile((FileToUpload, URLSessionDelegate))
        case headReportFile((FileToUpload, URLSessionDelegate))
    }
}

extension ReportRepository.API: APIRequest {
    
    var token: String? {
        
        switch self {
        case .createReport((let report, _)):
            return report.server?.accessToken
            
        case .putReportFile((let file, _)), .postReportFile((let file, _)), .headReportFile((let file, _)):
            return file.accessToken
        }
    }
    
    var keyValues: [Key : Value?]? {
        
        switch self {
        case .createReport((let report, _)):
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
        case .createReport((let report, _)):
            return report.server?.url ?? ""
            
        case .putReportFile((let file, _)), .postReportFile((let file, _)), .headReportFile((let file, _)):
            return file.serverURL
        }
    }
    
    var path: String {
        switch self {
        case .createReport:
            return "/report"
            
        case .putReportFile((let file,_)), .postReportFile((let file, _)), .headReportFile((let file, _)):
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
        case .putReportFile((let file, let delegate)), .headReportFile((let file, let delegate)), .postReportFile((let file, let delegate)):
            return URLSession(
                configuration: file.uploadOnBackground ? .background(withIdentifier: "org.wearehorizontal.tella") : .default,
                delegate: delegate,
                delegateQueue: nil)
            
        case .createReport((let report, let delegate)):
            
            return URLSession(
                configuration: report.server?.backgroundUpload ?? false ? .background(withIdentifier: "org.wearehorizontal.tella") : .default,
                delegate: delegate,
                delegateQueue: nil)
        }
    }
    
}
