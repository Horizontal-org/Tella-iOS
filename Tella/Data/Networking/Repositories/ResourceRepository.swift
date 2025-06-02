//
//  ResourceRepository.swift
//  Tella
//
//  Created by gus valbuena on 2/7/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

struct ResourceRepository: WebRepository {
    func getResourcesByProject(server: TellaServer) -> AnyPublisher<[Resource], APIError> {
        let apiResponse: APIResponse<[ProjectDTO]> = getAPIResponse(endpoint: API.getResourcesByProject(serverUrl: server.url ?? "", projectId: server.projectId ?? "", token: server.accessToken ?? ""))
        return apiResponse
            .compactMap{$0.0.first?.toDomain() as? Project}
            .compactMap{$0.resources}
            .eraseToAnyPublisher()
    }
    
    func getResourceByFileName(server: TellaServer, fileName: String) -> AnyPublisher<Data, APIError> {
        let apiResponse = getAPIResponseForBinaryData(endpoint: API.getResourceByFileName(serverUrl: server.url ?? "", fileName: fileName, token: server.accessToken ?? ""))
            
        return apiResponse
            .compactMap { $0.0 }
            .eraseToAnyPublisher()
    }
}

extension ResourceRepository {
    enum API {
        case getResourcesByProject(serverUrl: String, projectId: String, token: String)
        case getResourceByFileName(serverUrl: String, fileName: String, token: String)
    }
}

extension ResourceRepository.API: APIRequest {
    var token: String? {
        switch self {
        case .getResourcesByProject(_, _, let token), .getResourceByFileName(_, _, let token):
            return token
        }
    }
    
    var keyValues: [Key : Value?]? {
        return nil
    }
    
    var baseURL: String {
        switch self {

        case .getResourcesByProject(let serverUrl, _, _), .getResourceByFileName(let serverUrl, _, _):
            return serverUrl
        }
    }
    
    var path: String {
        switch self {
        case .getResourcesByProject(_, let projectId, _):
            return "/resource/projects?projectId[]=\(projectId)"
        case .getResourceByFileName(_, let fileName, _):
            return "/resource/mobile/asset/\(fileName)"
        }
    }
    
    var httpMethod: HTTPMethod {
        .get
    }
    var headers: [String : String]? {
        switch self {
        case .getResourcesByProject(_, _, _), .getResourceByFileName(_, _, _):
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        }
    }
}
