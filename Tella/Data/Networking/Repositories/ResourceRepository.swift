//
//  ResourceRepository.swift
//  Tella
//
//  Created by gus valbuena on 2/7/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

struct ResourceRepository: WebRepository {
    func getResourcesByProject(server: TellaServer) -> AnyPublisher<[ResourceDTO], APIError> {
        let apiResponse: APIResponse<[ResourceDTO]> = getAPIResponse(endpoint: API.getResourcesByProject(serverUrl: server.url ?? "", projectId: server.projectId ?? "", token: server.accessToken ?? ""))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }
}

extension ResourceRepository {
    enum API {
        case getResourcesByProject(serverUrl: String, projectId: String, token: String)
    }
}

extension ResourceRepository.API: APIRequest {
    
    // replace with server.accessToken in the future
    var token: String? {
        switch self {
        case.getResourcesByProject(_, _, let token):
            return token
        }
    }
    
    var keyValues: [Key : Value?]? {
        return nil
    }
    
    var baseURL: String {
        switch self {

        case .getResourcesByProject(let serverUrl, _, _):
            return serverUrl
        }
    }
    
    var path: String {
        switch self {
        case.getResourcesByProject(_, let projectId, _):
            return "/resource/projects?projectId[]=\(projectId)"
        }
    }
    
    var httpMethod: HTTPMethod {
        .get
    }
    var headers: [String : String]? {
        switch self {
        case .getResourcesByProject(_, _, _):
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        }
    }
}
