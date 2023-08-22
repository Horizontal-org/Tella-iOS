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
    var cancellable: AnyCancellable?
    private var subscribers = Set<AnyCancellable>()
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
                    case .failure(let error):
                       debugLog(error)
                    }

                }, receiveValue: { wrapper in
                    print(wrapper)
                }).store(in: &subscribers)
    }
    /// Return a collection of CollectedTemplate which is used to created after all the manpulation is done to prepare the template data for storage
    /// - Parameters:
    ///   - server: Server Object to get the information about the Uwazi server
    ///   - locale: UwaziLocale Object that has the locale information about language that the user selected when adding a new Uwazi server
    /// - Returns: Collection of CollectedTemplate
    func getTemplateNew(server: Server, locale: UwaziLocale) async throws  -> AnyPublisher<[CollectedTemplate], Error> {
        if let serverID = server.id, let serverURL = server.url {
            let cookieList = [server.accessToken ?? "", locale.locale ?? ""]

            let getTemplate = UwaziServerRepository().getTemplate(serverURL: serverURL, cookieList: cookieList)
            let getSetting = UwaziServerRepository().getSettings(serverURL: serverURL, cookieList: cookieList)
            let getDictionary = UwaziServerRepository().getDictionaries(serverURL: serverURL, cookieList: cookieList)
            let getTranslation = UwaziServerRepository().getTranslations(serverURL: serverURL, cookieList: cookieList)

            return Publishers.Zip4(
                getTemplate,
                getSetting,
                getDictionary,
                getTranslation
            )
            .tryMap { templateResult, settings, dictionary, translationResult in
                let templates = templateResult.rows
                let translations = translationResult.rows
                let dictionary = dictionary.rows

                // Maps the options to the property of the template
                templates.forEach { template in
                    template.properties.forEach { property in
                        dictionary.forEach { dictionaryItem in
                            if dictionaryItem.id == property.content {
                                property.values = dictionaryItem.values
                            }
                        }
                    }
                }

                var resultTemplates = [UwaziTemplate]()
                // Check whether the server instance is public and if public then only use the whitelisted templates are added to resultTemplates
                if (server.username?.isEmpty ?? true) || (server.password?.isEmpty ?? true) {
                    // allowedPublicTemplates get only the templates ids that are whitelisted
                    if !settings.allowedPublicTemplates.isEmpty {
                        templates.forEach { row in
                            settings.allowedPublicTemplates.forEach { id in
                                if row.id == id {
                                    resultTemplates.append(row)
                                }
                            }
                        }
                    }
                } else {
                    // This means its private instance and all the templates are added to resultTemplates
                    resultTemplates = templates
                }
                resultTemplates.forEach { template in
                    // Get only the translations based on the language that user selected
                    let filteredTranslations = translations.filter { row in
                        row.locale == locale.locale ?? ""
                    }
                    filteredTranslations.first?.contexts.forEach{ context in
                        // Compare context id and template id to determine appropiate translations
                        if context.contextID == template.id {
                            // Translation for the template name
                            template.translatedName = context.values?[template.name ?? ""] ?? ""
                            // Translation for the template's property texts or labels
                            template.properties.forEach { property in
                                property.translatedLabel = context.values?[property.label ?? ""] ?? ""
                            }
                            // Translation for the template's common properties texts or labels
                            template.commonProperties.forEach { property in
                                property.translatedLabel = context.values?[property.label ?? ""] ?? ""
                            }

                        } else {
                            // Translation for the template's property options texts or labels if there is any
                            template.properties.forEach { property in
                                property.values?.forEach { selectValue in
                                    if context.contextID == property.content {
                                        selectValue.translatedLabel = context.values?[selectValue.label ?? ""] ?? selectValue.label
                                    }
                                    // Translation for the template's property option's options texts or labels if there is any
                                    selectValue.values?.forEach { nestedSelectValue in
                                        if context.id == property.content {
                                            nestedSelectValue.translatedLabel = context.values?[nestedSelectValue.label ?? ""] ?? nestedSelectValue.label
                                        }
                                    }
                                }
                            }
                        }
                    }
                }


                let originalTemplate = resultTemplates.map { template in
                    return CollectedTemplate(serverId: serverID, templateId: template.id, serverName: server.name ?? "", username: server.username, entityRow: template, isDownloaded: 0, isFavorite: 0, isUpdated: 0 )
                }
                return originalTemplate
            }
            .eraseToAnyPublisher()
        }

        // Handle error case
        return Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
    }


    ///  Get all the templetes related to the Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  The array of string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziTemplateResult or APIError if any
    func getTemplate(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziTemplateResult, APIError> {
        let call :  AnyPublisher<UwaziTemplateResult, APIError> = call(endpoint: API.getTemplate(serverURL: serverURL, cookieList: cookieList))
        return call.eraseToAnyPublisher()
    }
    ///  Get all the setting related to the Uwazi server to determine the whitelisted templates
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  The array of string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziSettingResult or APIError if any
    func getSettings(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziSettingResult, APIError> {
        let call :  AnyPublisher<UwaziSettingResult, APIError> = call(endpoint: API.getSetting(serverURL: serverURL, cookieList: cookieList))
        return call.eraseToAnyPublisher()
    }
    ///  Get all the options that are related to properties of the template related to the selected Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  The array of string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziDictionaryResult or APIError if any
    func getDictionaries(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziDictionaryResult, APIError> {
        let call :  AnyPublisher<UwaziDictionaryResult, APIError> = call(endpoint: API.getDictionary(serverURL: serverURL, cookieList: cookieList))
        return call.eraseToAnyPublisher()
    }
    ///  Get all the translation of the text related to the selected Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  The array of string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziTranslationResult or APIError if any
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
