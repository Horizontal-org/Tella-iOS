//
//  UwaziServerRepositories.swift
//  Tella
//
//  Created by Robert Shrestha on 5/22/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation

enum ServerTokenType {
    case token(String)
    case none
}

struct UwaziServerRepository: WebRepository {

    func login(username: String,
               password: String,
               serverURL: String) -> AnyPublisher<ServerTokenType, APIError> {

        let apiResponse : APIResponse<BoolResponse> = getAPIResponse(endpoint: API.login((username: username, password: password, serverURL: serverURL)))
        return apiResponse
            .tryMap({ (response, allHeaderFields) in
                return handleToken(response: response, allHeaderFields: allHeaderFields)
            })
            .mapError {$0 as! APIError}
            .eraseToAnyPublisher()
    }

    func twoFactorAuthentication(username: String,
                                  password: String,
                                  token: String,
                                  serverURL: String) -> AnyPublisher<ServerTokenType, APIError> {

        let apiResponse : APIResponse<BoolResponse> = getAPIResponse(endpoint: API.twoFactorAuthentication((username: username, password: password,token: token, serverURL: serverURL)))
        return apiResponse
            .tryMap({ (response, allHeaderFields) in
                return handleToken(response: response, allHeaderFields: allHeaderFields)
            })
            .mapError {$0 as! APIError}
            .eraseToAnyPublisher()

    }
    private func handleToken(response: BoolResponse, allHeaderFields: [AnyHashable: Any]?) -> ServerTokenType {
        if response.success ?? false {
            guard let token = getTokenFromHeader(httpResponse: allHeaderFields) else { return .none}
            return (.token(token))
        } else {
            return .none
        }
    }
    private func getTokenFromHeader(httpResponse: [AnyHashable: Any]?) -> String? {
        if let token = httpResponse?["Set-Cookie"] as? String {
            let filteredToken = token.split(separator: ";")
            return filteredToken.first?.replacingOccurrences(of: "connect.sid=", with: "")
        }
        return nil
    }

    func checkServerURL(serverURL: String) -> AnyPublisher<UwaziCheckURL, APIError> {
        let apiResponse :  APIResponse<UwaziCheckURLDTO> = getAPIResponse(endpoint: API.checkURL(serverURL: serverURL))
        return apiResponse
            .compactMap{$0.0.toDomain() as? UwaziCheckURL}
            .eraseToAnyPublisher()
    }

    func getLanguage(serverURL: String) -> AnyPublisher<UwaziLanguage, APIError> {
        let apiResponse :  APIResponse<UwaziLanguageDTO> = getAPIResponse(endpoint: API.getLanguage(serverURL: serverURL))
        return apiResponse
            .compactMap{$0.0.toDomain() as? UwaziLanguage}
            .eraseToAnyPublisher()
    }

    func getProjetDetails(projectURL: String,token: String) -> AnyPublisher<ProjectAPI, APIError> {

        let apiResponse : APIResponse<ProjectDetailsResult> = getAPIResponse(endpoint: API.getProjetDetails((projectURL: projectURL, token: token)))

        return apiResponse
            .compactMap{$0.0.toDomain() as? ProjectAPI }
            .eraseToAnyPublisher()
    }
}

extension UwaziServerRepository {
    enum API {
        case login((username: String,
                    password: String,
                    serverURL: String))

        case getProjetDetails((projectURL:String, token: String))
        case checkURL(serverURL: String)
        case getLanguage(serverURL: String)
        case twoFactorAuthentication((username: String,
                                      password: String,
                                      token: String,
                                      serverURL: String))
    }
}

extension UwaziServerRepository.API: APIRequest {

    var token: String? {
        switch self {
        case .login, .twoFactorAuthentication:
            return nil
        case .getProjetDetails((_, let token)):
            return token
        case .checkURL, .getLanguage:
            return nil
        }
    }

    var keyValues: [Key : Value?]? {

        switch self {
        case .login((let username, let password, _ )):
            return [
                "username": username,
                "password": password
            ]
        case .getProjetDetails(_):
            return nil
        case .twoFactorAuthentication((let username, let password, let token, _)):
            return [
                "username": username,
                "password": password,
                "token": token
            ]
        case .checkURL, .getLanguage:
            return nil
        }
    }

    var baseURL: String {
        switch self {
        case .login((_, _, let serverURL)), .twoFactorAuthentication((_,_,_, let serverURL)):
            return serverURL
        case .getProjetDetails((let projectURL, _)):
            return projectURL
        case .checkURL(serverURL: let serverURL) ,.getLanguage(serverURL: let serverURL):
            return serverURL
        }
    }

    var path: String {
        switch self {
        case .login, .twoFactorAuthentication:
            return "/api/login"
        case .getProjetDetails(_):
            return ""
        case .checkURL:
            return "/api/settings"
        case .getLanguage:
            return "/api/translations"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login, .twoFactorAuthentication:
            return HTTPMethod.post
        case .getProjetDetails(_):
            return HTTPMethod.get
        case .checkURL, .getLanguage:
            return HTTPMethod.get
        }
    }
}
