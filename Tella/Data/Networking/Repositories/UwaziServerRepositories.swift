//
//  UwaziServerRepositories.swift
//  Tella
//
//  Created by Robert Shrestha on 5/22/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Combine
import Foundation


struct UwaziCombinedResults {
    let templateResult: UwaziTemplateResult
    let settingResult: UwaziSettingResult
    let dictionaryResult: UwaziDictionaryResult
    let translationResult: UwaziTranslationResult
}

class UwaziServerRepository: WebRepository {
    private var subscribers = Set<AnyCancellable>()
    var settingsSubscription: AnyCancellable?
    func login(username: String,
               password: String,
               serverURL: String) -> AnyPublisher<(UwaziLoginResult,HTTPURLResponse?), APIError> {

        let call : AnyPublisher<(UwaziLoginResult,HTTPURLResponse?), APIError> = callReturnsHeaders(endpoint: API.login((username: username, password: password, serverURL: serverURL)))

        return call
            .eraseToAnyPublisher()
    }

    func twoFactorAuthentication(username: String,
                                  password: String,
                                  token: String,
                                  serverURL: String) -> AnyPublisher<(UwaziLoginResult,HTTPURLResponse?), APIError> {

        let call : AnyPublisher<(UwaziLoginResult,HTTPURLResponse?), APIError> = callReturnsHeaders(endpoint: API.twoFactorAuthentication((username: username, password: password,token: token, serverURL: serverURL)))

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
    func handleTemplate(serverURL: String, cookieList: [String]) {
        self.getTranslations(serverURL: serverURL, cookieList: cookieList)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Finished")
                        // TODO: handle this error
                    case .failure(let error):
                       print(error)
                    }

                }, receiveValue: { wrapper in
                    print(wrapper)
                }).store(in: &subscribers)
    }
    func getTemplate(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziTemplateResult, APIError> {
        let call :  AnyPublisher<UwaziTemplateResult, APIError> = call(endpoint: API.getTemplate(serverURL: serverURL, cookieList: cookieList))
        return call.eraseToAnyPublisher()
    }
    func getSettings(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziSettingResult, APIError> {
        let call :  AnyPublisher<UwaziSettingResult, APIError> = call(endpoint: API.getSetting(serverURL: serverURL, cookieList: cookieList))
        return call.eraseToAnyPublisher()
    }
    func getDictionaries(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziDictionaryResult, APIError> {
        let call :  AnyPublisher<UwaziDictionaryResult, APIError> = call(endpoint: API.getDictionary(serverURL: serverURL, cookieList: cookieList))
        return call.eraseToAnyPublisher()
    }
    func getTranslations(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziTranslationResult, APIError> {
        let call :  AnyPublisher<UwaziTranslationResult, APIError> = call(endpoint: API.getTranslations(serverURL: serverURL, cookieList: cookieList))
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
        case getTemplate(serverURL: String, cookieList:[String])
        case getSetting(serverURL: String, cookieList:[String])
        case getDictionary(serverURL: String, cookieList:[String])
        case getTranslations(serverURL: String, cookieList:[String])
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
        case .getTemplate,.getSetting, .getDictionary, .getTranslations:
            return nil
        }
    }

    var headers: [String: String]? {
        switch self {

        case .login, .getProjetDetails, .checkURL, .getLanguage, .twoFactorAuthentication:
             return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        case .getTemplate(_,let cookieList), .getSetting(_,let cookieList), .getDictionary(_,let cookieList), .getTranslations(_,let cookieList):
            let cookiesString = cookieList.joined(separator: "; ")
            return ["Cookie": cookiesString,
                    HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
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
        case .checkURL, .getLanguage, .getTemplate, .getSetting,.getDictionary,.getTranslations:
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
        case .getTemplate(serverURL: let serverURL, cookieList: _):
            return serverURL
        case .getSetting(serverURL: let serverURL, cookieList: _), .getDictionary(serverURL: let serverURL, cookieList: _),.getTranslations(serverURL: let serverURL, cookieList: _):
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
        case .getTemplate:
            return "/api/templates"
        case .getSetting:
            return "/api/settings"
        case .getDictionary:
            return "/api/dictionaries"
        case .getTranslations:
            return "/api/translations"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login, .twoFactorAuthentication:
            return HTTPMethod.post
        case .getProjetDetails(_):
            return HTTPMethod.get
        case .checkURL, .getLanguage, .getSetting, .getTemplate,.getDictionary,.getTranslations:
            return HTTPMethod.get
        }
    }
}
