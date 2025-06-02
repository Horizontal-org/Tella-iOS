//
//  PeerToPeerRepository.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import Foundation
import Combine

class PeerToPeerRepository: NSObject, WebRepository {
    
    var connectionInfo:ConnectionInfo?
    
    func getHash(connectionInfo:ConnectionInfo) -> AnyPublisher<String, Error> {
        
        let apiResponse = fetchServerPublicKeyHash(endpoint: API.getHash(connectionInfo: connectionInfo))
        return apiResponse
            .eraseToAnyPublisher()
    }
    
    func register(connectionInfo:ConnectionInfo, registerRequest:RegisterRequest) -> AnyPublisher<RegisterResponse, APIError> {
        
        let apiResponse : APIResponse<RegisterResponse> = getLocalAPIResponse(endpoint: API.register(connectionInfo:connectionInfo,
                                                                                                registerRequest: registerRequest))
        return apiResponse
            .compactMap{$0.response}
            .handleEvents(receiveOutput: { [weak self] result in
                self?.connectionInfo = connectionInfo
            })
            .eraseToAnyPublisher()
    }
    
    func prepareUpload(prepareUpload: PrepareUploadRequest) -> AnyPublisher<PrepareUploadResponse, APIError> {
        
        guard let connectionInfo else {return Fail(error: APIError.badServer)
            .eraseToAnyPublisher()}
        
        let apiResponse : APIResponse<PrepareUploadResponse> = getLocalAPIResponse(
            endpoint: API.prepareUpload(connectionInfo:connectionInfo,
                                        prepareUpload: prepareUpload))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
    
    func uploadFile( fileUploadRequest:FileUploadRequest) -> AnyPublisher<BoolResponse, APIError> {
        guard let connectionInfo else {return Fail(error: APIError.badServer)
            .eraseToAnyPublisher()}
        
        do {
            let apiResponse : APIResponse<BoolResponse> = getLocalAPIResponse(
                endpoint: API.uploadFile(connectionInfo:connectionInfo,
                                         fileUploadRequest: fileUploadRequest))
            return apiResponse
                .compactMap{$0.response}
                .eraseToAnyPublisher()
        }
    }
    @discardableResult
    func closeConnection(closeConnectionRequest: CloseConnectionRequest) -> AnyPublisher<BoolResponse, APIError> {
        guard let connectionInfo else {return Fail(error: APIError.badServer)
            .eraseToAnyPublisher()}
        
        let apiResponse : APIResponse<BoolResponse> = getLocalAPIResponse(endpoint: API.closeConnection(connectionInfo:connectionInfo,
                                                                                                   closeConnectionRequest: closeConnectionRequest))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
}

extension PeerToPeerRepository {
    
    enum API {
        case getHash(connectionInfo:ConnectionInfo)
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
        case .getHash:
            return nil
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
        case .getHash:
            return nil
        case .uploadFile:
            return [HTTPHeaderField.contentType.rawValue : ContentType.data.rawValue]
        default:
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        }
    }
    
    var baseURL: String {
        switch self {
        case .getHash(let connectionInfos),
                .register(let connectionInfos, _),
                .prepareUpload(let connectionInfos, _),
                .uploadFile(let connectionInfos, _),
                .closeConnection(let connectionInfos, _):
            return "https://" + connectionInfos.ipAddress + ":\(connectionInfos.port)"
        }
    }
    
    var path: String? {
        switch self {
        case .register:
            return PeerToPeerEndpoint.register.rawValue
            
        case .prepareUpload:
            return  PeerToPeerEndpoint.prepareUpload.rawValue
            
        case .uploadFile:
            return  PeerToPeerEndpoint.upload.rawValue
            
        case .closeConnection:
            return PeerToPeerEndpoint.closeConnection.rawValue
            
        case .getHash:
            return nil
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .register, .prepareUpload, .uploadFile, .closeConnection, .getHash:
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
        case .register( let connectionInfo, _),
                .prepareUpload(let connectionInfo, _),
                .uploadFile(let connectionInfo, _),
                .closeConnection(let connectionInfo, _):
            return connectionInfo.certificateHash
            
        default:
            return nil
        }
    }
}
