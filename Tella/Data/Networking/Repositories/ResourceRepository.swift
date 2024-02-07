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
    func getResourcesByProject(serverUrl: String, projectIds: [String]) -> AnyPublisher<[ResourceDTO], APIError> {
        let apiResponse: APIResponse<[ResourceDTO]> = getAPIResponse(endpoint: API.getResourcesByProject(serverUrl: serverUrl, projectIds: projectIds))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }
}

extension ResourceRepository {
    enum API {
        case getResourcesByProject(serverUrl: String, projectIds: [String])
    }
}

extension ResourceRepository.API: APIRequest {
    
    var token: String? {
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2ZDhmMDYwNy1lOGQ2LTQzYjMtYmVmOC05YTk0NDkwYzg4ZDIiLCJ0eXBlIjoid2ViIiwiaWF0IjoxNzA3MzMwOTUzLCJleHAiOjE3MDc0MTczNTN9.9esvNWiNUfHVEpxFMHrjRsPqGv5LVu3Ns3W9BGNg1_A"
    }
    
    var keyValues: [Key : Value?]? {
        return nil
    }
    
    var baseURL: String {
        switch self {

        case .getResourcesByProject(let serverUrl, _):
            return serverUrl
        }
    }
    
    var path: String {
        switch self {
        case.getResourcesByProject(_, let projectIds):
            let projectIdParams = projectIds.map { "projectId[]=\($0)" }.joined(separator: "&")
            
            return "/resource/projects?\(projectIdParams)"
        }
    }
    
    var httpMethod: HTTPMethod {
        .get
    }
    var headers: [String : String]? {
        switch self {
        case .getResourcesByProject(_, _):
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        }
    }
}
