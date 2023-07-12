//
//  UwaziServerRepositories.swift
//  Tella
//
//  Created by Robert Shrestha on 5/22/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Combine
import Foundation

struct UwaziServerRepository: WebRepository {

    func login(username: String,
               password: String,
               serverURL: String) -> AnyPublisher<(UwaziLoginResult,HTTPURLResponse?), APIError> {

        let call : AnyPublisher<(UwaziLoginResult,HTTPURLResponse?), APIError> = callNew(endpoint: API.login((username: username, password: password, serverURL: serverURL)))

        return call
            .eraseToAnyPublisher()
    }

    func twoFactorAuthentication(username: String,
                                  password: String,
                                  token: String,
                                  serverURL: String) -> AnyPublisher<UwaziLoginResult, APIError> {

        let call : AnyPublisher<UwaziLoginResult, APIError> = call(endpoint: API.twoFactorAuthentication((username: username, password: password,token: token, serverURL: serverURL)))

        return call
            .eraseToAnyPublisher()

    }

    func checkServerURL(serverURL: String) -> AnyPublisher<UwaziCheckURLResult, APIError> {
        let call :  AnyPublisher<UwaziCheckURLResult, APIError> = call(endpoint: API.checkURL(serverURL: serverURL))
        return call.eraseToAnyPublisher()
    }

    func getLanguage(serverURL: String) -> AnyPublisher<UwaziLanguageResult, APIError> {
        let call :  AnyPublisher<UwaziLanguageResult, APIError> = call(endpoint: API.getLanguage(serverURL: serverURL))
        return call.eraseToAnyPublisher()
    }

    func getProjetDetails(projectURL: String,token: String) -> AnyPublisher<ProjectAPI, APIError> {

        let call : AnyPublisher<ProjectDetailsResult, APIError> = call(endpoint: API.getProjetDetails((projectURL: projectURL, token: token)))

        return call
            .compactMap{$0.toDomain() as? ProjectAPI }
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
