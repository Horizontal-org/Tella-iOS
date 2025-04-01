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
    
    func register(serverURL :String, registerRequest:RegisterRequest, trustedPublicKeyHash: String) -> AnyPublisher<RegisterResponse, APIError> {
        
        let apiResponse : APIResponse<RegisterResponse> = getAPIResponse(endpoint: API.register(serverURL:serverURL,
                                                                                                registerRequest: registerRequest, trustedPublicKeyHash: trustedPublicKeyHash))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }
    
    func prepareUpload(serverURL: String, prepareUpload: PrepareUploadRequest) -> AnyPublisher<PrepareUploadResponse, APIError> {
        let apiResponse : APIResponse<PrepareUploadResponse> = getAPIResponse(endpoint: API.prepareUpload(serverURL: serverURL,
                                                                                                          prepareUpload: prepareUpload))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }
    
    func uploadFile(serverURL: String, fileUploadRequest:FileUploadRequest) -> AnyPublisher<BoolResponse, APIError> {
        do {
            let apiResponse : APIResponse<BoolResponse> = getAPIResponse(endpoint: API.uploadFile(serverURL: serverURL,
                                                                                                  fileUploadRequest: fileUploadRequest))
            return apiResponse
                .compactMap{$0.0}
                .eraseToAnyPublisher()
        }
    }
    
    func closeConnection(serverURL: String, closeConnectionRequest: CloseConnectionRequest) -> AnyPublisher<BoolResponse, APIError> {
        let apiResponse : APIResponse<BoolResponse> = getAPIResponse(endpoint: API.closeConnection(serverURL: serverURL,
                                                                                                   closeConnectionRequest: closeConnectionRequest))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }
}

extension PeerToPeerRepository {
    
    enum API {
        case register(serverURL :String, registerRequest:RegisterRequest,trustedPublicKeyHash: String)
        case prepareUpload(serverURL: String, prepareUpload: PrepareUploadRequest)
        case uploadFile(serverURL: String, fileUploadRequest:FileUploadRequest)
        case closeConnection(serverURL: String, closeConnectionRequest: CloseConnectionRequest)
    }
}

extension PeerToPeerRepository.API: APIRequest {
    
    typealias Value = Any
    
    var keyValues: [Key : Value?]? {
        
        switch self {
        case .register(_, let registerRequest,_):
            return registerRequest.dictionary
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
        case .register(let serverURL, _, _):
            return "https://" + serverURL
        case .prepareUpload(let serverURL, _):
            return "https://" + serverURL
        case .uploadFile(let serverURL,_):
            return "https://" + serverURL
        case .closeConnection(let serverURL,_):
            return "https://" + serverURL
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return ":53317/api/v1/register"
            
        case .prepareUpload:
            return ":53317/api/v1/prepare-upload"
            
        case .uploadFile:
            return ":53317/api/v1/upload"
            
        case .closeConnection:
            return ":53317/api/v1/close-connection"
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
        case .uploadFile (_,let fileUploadRequest):
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
        case .register(_, _, let trustedPublicKeyHash):
            return trustedPublicKeyHash
            
        default:
            return nil
        }

    }
}
