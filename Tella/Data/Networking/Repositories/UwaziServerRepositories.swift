//
//  UwaziServerRepositories.swift
//  Tella
//
//  Created by Robert Shrestha on 5/22/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Combine
import Foundation

class UwaziServerRepository: WebRepository {
    var cancellable: AnyCancellable?
    func login(username: String,
               password: String,
               serverURL: String) -> AnyPublisher<String?, APIError> {

        let apiResponse : APIResponse<BoolResponse> = getAPIResponse(endpoint: API.login((username: username, password: password, serverURL: serverURL)))
        return apiResponse
            .tryMap({ (response, allHeaderFields) in
                let token = self.handleToken(response: response, allHeaderFields: allHeaderFields)
                return token
            })
            .mapError {$0 as! APIError}
            .eraseToAnyPublisher()
    }

    func twoFactorAuthentication(username: String,
                                 password: String,
                                 token: String,
                                 serverURL: String) -> AnyPublisher<String?, APIError> {

        let apiResponse : APIResponse<BoolResponse> = getAPIResponse(endpoint: API.twoFactorAuthentication((username: username, password: password,token: token, serverURL: serverURL)))
        return apiResponse
            .tryMap({ (response, allHeaderFields) in
                return self.handleToken(response: response, allHeaderFields: allHeaderFields)
            })
            .mapError {$0 as! APIError}
            .eraseToAnyPublisher()
    }

    private func handleToken(response: BoolResponse, allHeaderFields: [AnyHashable: Any]?) -> String? {
        if response.success ?? false {
            guard let token = getTokenFromHeader(httpResponse: allHeaderFields) else { return nil }
            return token
        } else {
            return nil
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
        let apiResponse: APIResponse<UwaziCheckURLDTO> = getAPIResponse(endpoint: API.checkURL(serverURL: serverURL))
        return apiResponse
            .compactMap{$0.0.toDomain() as? UwaziCheckURL}
            .eraseToAnyPublisher()
    }

    func getLanguage(serverURL: String) -> AnyPublisher<UwaziLanguage, APIError> {
        let apiResponse: APIResponse<UwaziLanguageDTO> = getAPIResponse(endpoint: API.getLanguage(serverURL: serverURL))
        return apiResponse
            .compactMap{$0.0.toDomain() as? UwaziLanguage}
            .eraseToAnyPublisher()
    }

    ///  Get all the templetes related to the Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  The array of string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziTemplateResult or APIError if any
    func getTemplate(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziTemplateDTO, APIError> {
        let apiResponse: APIResponse<UwaziTemplateDTO> = getAPIResponse(endpoint: API.getTemplate(serverURL: serverURL, cookieList: cookieList))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }
    ///  Get all the setting related to the Uwazi server to determine the whitelisted templates
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  The array of string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziSettingResult or APIError if any
    func getSettings(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziSettingDTO, APIError> {
        let apiResponse:  APIResponse<UwaziSettingDTO> = getAPIResponse(endpoint: API.getSetting(serverURL: serverURL, cookieList: cookieList))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }
    ///  Get all the options that are related to properties of the template related to the selected Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  The array of string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziDictionaryResult or APIError if any
    func getDictionaries(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziDictionaryDTO, APIError> {
        let apiResponse: APIResponse<UwaziDictionaryDTO> = getAPIResponse(endpoint: API.getDictionary(serverURL: serverURL, cookieList: cookieList))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }
    ///  Get all the translation of the text related to the selected Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  The array of string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziTranslationResult or APIError if any
    func getTranslations(serverURL: String, cookieList: [String]) -> AnyPublisher<UwaziTranslationDTO, APIError> {
        let apiResponse: APIResponse<UwaziTranslationDTO> = getAPIResponse(endpoint: API.getTranslations(serverURL: serverURL, cookieList: cookieList))
        return apiResponse
            .compactMap{$0.0}
            .eraseToAnyPublisher()
    }

    func getProjetDetails(projectURL: String,token: String) -> AnyPublisher<ProjectAPI, APIError> {
        let apiResponse : APIResponse<ProjectDetailsResult> = getAPIResponse(endpoint: API.getProjetDetails((projectURL: projectURL, token: token)))
        return apiResponse
            .compactMap{$0.0.toDomain() as? ProjectAPI }
            .eraseToAnyPublisher()
    }
    
    func submitEntity(serverURL: String, cookieList: [String], entity: [String: Any]) -> AnyPublisher<EntityCreationResponse, APIError> {
            let apiResponse: APIResponse<EntityCreationResponse> = getAPIResponse(endpoint: API.submitEntity(serverURL: serverURL, cookieList: cookieList, entity: entity))

            return apiResponse
                .compactMap{$0.0}
                .eraseToAnyPublisher()
        }
}
extension UwaziServerRepository {
    /// Return a collection of CollectedTemplate which is used to created after all the manpulation is done to prepare the template data for storage
    /// - Parameters:
    ///   - server: Server Object to get the information about the Uwazi server
    ///   - locale: UwaziLocale Object that has the locale information about language that the user selected when adding a new Uwazi server
    /// - Returns: Collection of CollectedTemplate
    func handleTemplate(server: Server, locale: UwaziLocale) async throws  -> AnyPublisher<[UwaziTemplateRow], Error> {
        guard let serverURL = server.url else {
            return Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
        }
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
        .tryMap({ (templateResult, settings, dictionary, translationResult) in
            let templates = templateResult.rows
            let translations = translationResult.rows
            let dictionary = dictionary.rows
            let settings: UwaziSettingDTO = settings

            // Maps the options to the property of the template
            self.handleMapping(templates, dictionary)
            // Check whether the server instance is public and if public then only use the whitelisted templates are added to resultTemplates
            let resultTemplates = self.getAllowedTemplates(server: server, settings: settings, templates: templates)
            self.translate(locale: locale, resultTemplates: resultTemplates, translations: translations)
            return resultTemplates.compactMap({$0.toDomain() as? UwaziTemplateRow})
        })
        .eraseToAnyPublisher()
    }

    fileprivate func getAllowedTemplates(server: Server, settings: UwaziSettingDTO, templates: [UwaziTemplateRowDTO]?) -> [UwaziTemplateRowDTO] {
        // Check whether the server instance is public and if public then only use the whitelisted templates are added to resultTemplates
        var tempTemplates: [UwaziTemplateRowDTO] = []
        if !self.isPublic(server: server) {
            tempTemplates = templates ?? []
        } else {
            if !settings.allowedPublicTemplates.isEmpty {
                templates?.forEach { row in
                    settings.allowedPublicTemplates.forEach { id in
                        if row.id == id {
                            tempTemplates.append(row)
                        }
                    }
                }
            }
        }
        return tempTemplates
    }

    fileprivate func isPublic(server: Server) -> Bool {
        return (server.username?.isEmpty ?? true) || (server.password?.isEmpty ?? true)
    }

    // Maps the options to the property of the template
    fileprivate func handleMapping(_ templates: [UwaziTemplateRowDTO]?, _ dictionary: [UwaziDictionaryRowDTO]?) {
        templates?.forEach { template in
            template.properties.forEach { property in
                if let dictionaryItem = dictionary?.first(where: { $0.id == property.content }) {
                    property.values = dictionaryItem.values
                }
            }
        }
    }

    fileprivate func translate(locale: UwaziLocale, resultTemplates: [UwaziTemplateRowDTO], translations: [UwaziTranslationRowDTO]?) {
        resultTemplates.forEach { template in
            // Get only the translations based on the language that user selected
            let filteredTranslations = translations?.filter{$0.locale == locale.locale ?? ""}
            filteredTranslations?.first?.contexts.forEach{ context in
                // Compare context id and template id to determine appropiate translations
                if context.contextID == template.id {
                    handleTranslationForTemplate(template: template, context: context)
                } else {
                    handleTranslationForOtherProperties(template: template, context: context)
                }
            }
        }
    }

    fileprivate func handleTranslationForTemplate(template: UwaziTemplateRowDTO, context: UwaziTranslationContextDTO) {
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
    }

    fileprivate func handleTranslationForOtherProperties(template: UwaziTemplateRowDTO, context: UwaziTranslationContextDTO) {
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
        case submitEntity(serverURL: String, cookieList: [String], entity: [String: Any])
    }
}

extension UwaziServerRepository.API: APIRequest {
    typealias Value = Any
    var token: String? {
        switch self {
        case .login, .twoFactorAuthentication:
            return nil
        case .getProjetDetails((_, let token)):
            return token
        case .checkURL, .getLanguage:
            return nil
        case .getTemplate,.getSetting, .getDictionary, .getTranslations, .submitEntity:
            return nil
        }
    }

    var headers: [String: String]? {
        switch self {
        case .login, .getProjetDetails, .checkURL, .getLanguage, .twoFactorAuthentication:
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        case .getTemplate(_,let cookieList), .getSetting(_,let cookieList), .getDictionary(_,let cookieList), .getTranslations(_,let cookieList):
            let cookiesString = cookieList.joined(separator: "; ")
            return [HTTPHeaderField.cookie.rawValue: cookiesString,
                    HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        case .submitEntity(_, let cookieList, _):
                    let cookiesString = cookieList.joined(separator: ";")
            return [HTTPHeaderField.cookie.rawValue: cookiesString,
                    HTTPHeaderField.xRequestedWith.rawValue: XRequestedWithValue.xmlHttp.rawValue,
                    HTTPHeaderField.contentType.rawValue : ContentType.data.rawValue ]
        }
    }
    
    var encoding: Encoding {
        switch self {
        case .submitEntity:
            return Encoding.form
        default:
            return Encoding.json
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
        case .submitEntity(_, _, let entity):
            return entity
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
        case .getSetting(serverURL: let serverURL, cookieList: _), .getDictionary(serverURL: let serverURL, cookieList: _),.getTranslations(serverURL: let serverURL, cookieList: _), .submitEntity(serverURL: let serverURL, cookieList: _, entity: _):
            return serverURL
        }
    }

    var path: String {
        switch self {
        case .login, .twoFactorAuthentication:
            return "/api/login"
        case .getProjetDetails(_):
            return ""
        case .checkURL,.getSetting:
            return "/api/settings"
        case .getLanguage:
            return "/api/translations"
        case .getTemplate:
            return "/api/templates"
        case .getDictionary:
            return "/api/dictionaries"
        case .getTranslations:
            return "/api/translations"
        case .submitEntity:
            return "/api/entities"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login, .twoFactorAuthentication, .submitEntity:
            return HTTPMethod.post
        case .getProjetDetails(_):
            return HTTPMethod.get
        case .checkURL, .getLanguage, .getSetting, .getTemplate,.getDictionary,.getTranslations:
            return HTTPMethod.get
        }
    }
}
