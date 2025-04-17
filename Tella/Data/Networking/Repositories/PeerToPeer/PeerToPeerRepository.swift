//
//  LocalsendRepository.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class PeerToPeerRepository: NSObject, WebRepository {
    
    var connectionInfo:ConnectionInfo?
    
    func register(connectionInfo:ConnectionInfo, registerRequest:RegisterRequest) -> AnyPublisher<RegisterResponse, APIError> {
        
        let apiResponse : APIResponse<RegisterResponse> = getAPIResponse(endpoint: API.register(connectionInfo:connectionInfo,
                                                                                                registerRequest: registerRequest))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
    
    func prepareUpload(prepareUpload: PrepareUploadRequest) -> AnyPublisher<PrepareUploadResponse, APIError> {
        
        guard let connectionInfo else {return Fail(error: APIError.badServer)
            .eraseToAnyPublisher()}
        
        let apiResponse : APIResponse<PrepareUploadResponse> = getAPIResponse(endpoint: API.prepareUpload(connectionInfo:connectionInfo,
                                                                                                          prepareUpload: prepareUpload))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
    
    func uploadFile( fileUploadRequest:FileUploadRequest) -> AnyPublisher<BoolResponse, APIError> {
        guard let connectionInfo else {return Fail(error: APIError.badServer)
            .eraseToAnyPublisher()}
        
        do {
            let apiResponse : APIResponse<BoolResponse> = getAPIResponse(endpoint: API.uploadFile(connectionInfo:connectionInfo,
                                                                                                  fileUploadRequest: fileUploadRequest))
            return apiResponse
                .compactMap{$0.response}
                .eraseToAnyPublisher()
        }
    }
    
    func closeConnection(closeConnectionRequest: CloseConnectionRequest) -> AnyPublisher<BoolResponse, APIError> {
        guard let connectionInfo else {return Fail(error: APIError.badServer)
            .eraseToAnyPublisher()}
        
        let apiResponse : APIResponse<BoolResponse> = getAPIResponse(endpoint: API.closeConnection(connectionInfo:connectionInfo,
                                                                                                   closeConnectionRequest: closeConnectionRequest))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
}

extension PeerToPeerRepository {
    
    enum API {
        case register(connectionInfo:ConnectionInfo, registerRequest:RegisterRequest)
        case prepareUpload(connectionInfo:ConnectionInfo, prepareUpload: PrepareUploadRequest)
        case uploadFile(connectionInfo:ConnectionInfo, fileUploadRequest:FileUploadRequest)
        case closeConnection(connectionInfo:ConnectionInfo, closeConnectionRequest: CloseConnectionRequest)
    }
}

extension PeerToPeerRepository.API: APIRequest {
    
    typealias Value = Any
    
    var keyValues: [Key : Value?]? {
        
        switch self {
        case .register(_, let registerRequest):
            return registerRequest .dictionary
        case .prepareUpload(_, let prepareUpload):
            return prepareUpload.dictionary
        case .uploadFile:
            return nil
        case .closeConnection(_, let closeConnectionRequest):
            return closeConnectionRequest.dictionary
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .uploadFile:
            return [HTTPHeaderField.contentType.rawValue : ContentType.data.rawValue]
            
        default:
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        }
    }
    
    var baseURL: String {
        switch self {
        case .register(let connectionInfos, _):
            return "https://" + connectionInfos.ipAddress + ":\(connectionInfos.port)"
        case .prepareUpload(let connectionInfos, _):
            return "https://" + connectionInfos.ipAddress + ":\(connectionInfos.port)"
        case .uploadFile(let connectionInfos, _):
            return "https://" + connectionInfos.ipAddress + ":\(connectionInfos.port)"
        case .closeConnection(let connectionInfos, _):
            return "https://" + connectionInfos.ipAddress + ":\(connectionInfos.port)"
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return PeerToPeerEndpoint.register.rawValue
            
        case .prepareUpload:
            return  PeerToPeerEndpoint.prepareUpload.rawValue
            
        case .uploadFile:
            return  PeerToPeerEndpoint.upload.rawValue
            
        case .closeConnection:
            return PeerToPeerEndpoint.closeConnection.rawValue
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .register, .prepareUpload, .uploadFile, .closeConnection:
            return HTTPMethod.post
        }
    }
    
    var multipartBody: Data? {
        switch self {
        case .uploadFile (_, let fileUploadRequest):
            return fileUploadRequest.data
            
        default:
            return nil
        }
    }
    
    var encoding: Encoding {
        switch self {
        case .uploadFile:
            return .form
        default:
            return .json
        }
    }
    
    var trustedPublicKeyHash: String? {
        switch self {
        case .register( let connectionInfos, _):
            return connectionInfos.certificateHash
            
        default:
            return nil
        }
    }
}
