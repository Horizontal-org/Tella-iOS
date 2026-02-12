//
//  UwaziServerRepositories.swift
//  Tella
//
//  Created by Robert Shrestha on 5/22/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
            .tryMap({ apiResponse in
                let token = self.handleToken(response: apiResponse.response, allHeaderFields: apiResponse.headers)
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
            .tryMap({ apiResponse in
                return self.handleToken(response: apiResponse.response, allHeaderFields: apiResponse.headers)
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

    func checkServerURL(serverURL: String, cookie: String) -> AnyPublisher<UwaziCheckURL, APIError> {
        let apiResponse: APIResponse<UwaziCheckURLDTO> = getAPIResponse(endpoint: API.checkURL(serverURL: serverURL, cookie: cookie))
        return apiResponse
            .compactMap{$0.response.toDomain() as? UwaziCheckURL}
            .eraseToAnyPublisher()
    }

    func getLanguage(serverURL: String, cookie: String) -> AnyPublisher<UwaziLanguage, APIError> {
        let apiResponse: APIResponse<UwaziLanguageDTO> = getAPIResponse(endpoint: API.getLanguage(serverURL: serverURL, cookie: cookie))
        return apiResponse
            .compactMap{$0.response.toDomain() as? UwaziLanguage}
            .eraseToAnyPublisher()
    }

    ///  Get all the templetes related to the Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziTemplateResult or APIError if any
    func getTemplate(serverURL: String, cookieList: String) -> AnyPublisher<UwaziTemplateDTO, APIError> {
        let apiResponse: APIResponse<UwaziTemplateDTO> = getAPIResponse(endpoint: API.getTemplate(serverURL: serverURL, cookieList: cookieList))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
    ///  Get all the setting related to the Uwazi server to determine the whitelisted templates
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziSettingResult or APIError if any
    func getSettings(serverURL: String, cookieList: String) -> AnyPublisher<UwaziSettingDTO, APIError> {
        let apiResponse:  APIResponse<UwaziSettingDTO> = getAPIResponse(endpoint: API.getSetting(serverURL: serverURL, cookieList: cookieList))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
    ///  Get all the options that are related to properties of the template related to the selected Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziDictionaryResult or APIError if any
    func getDictionaries(serverURL: String, cookieList: String) -> AnyPublisher<UwaziDictionaryDTO, APIError> {
        let apiResponse: APIResponse<UwaziDictionaryDTO> = getAPIResponse(endpoint: API.getDictionary(serverURL: serverURL, cookieList: cookieList))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }
    ///  Get all the translation of the text related to the selected Uwazi server
    /// - Parameters:
    ///   - serverURL: the URL of the server
    ///   - cookieList:  string which consist of  token and the locale of the selected uwazi server if public instance then the array is empty
    /// - Returns: AnyPublisher with UwaziTranslationResult or APIError if any
    func getTranslations(serverURL: String, cookieList: String) -> AnyPublisher<UwaziTranslationDTO, APIError> {
        let apiResponse: APIResponse<UwaziTranslationDTO> = getAPIResponse(endpoint: API.getTranslations(serverURL: serverURL, cookieList: cookieList))
        return apiResponse
            .compactMap{$0.response}
            .eraseToAnyPublisher()
    }

    func getProjetDetails(projectURL: String,token: String) -> AnyPublisher<ProjectAPI, APIError> {
        let apiResponse : APIResponse<ProjectDetailsResult> = getAPIResponse(endpoint: API.getProjetDetails((projectURL: projectURL, token: token)))
        return apiResponse
            .compactMap{$0.response.toDomain() as? ProjectAPI }
            .eraseToAnyPublisher()
    }
    
    func submitEntity(serverURL: String, cookie: String, multipartHeader: String, multipartBody: Data, isPublic: Bool) -> AnyPublisher<EntityResult, APIError> {
            if isPublic {
                let apiResponse: APIResponse<Entity> = getAPIResponse(endpoint: API.submitPublicEntity(serverURL: serverURL, cookie: cookie, multipartHeader: multipartHeader, multipartBody: multipartBody))
                    return apiResponse
                    .compactMap{ response in
                        EntityResult.publicEntity(response.response)
                    }
                    .eraseToAnyPublisher()
            }
        
            let apiResponse: APIResponse<EntityCreationResponse> = getAPIResponse(endpoint: API.submitEntity(serverURL: serverURL, cookie: cookie, multipartHeader: multipartHeader, multipartBody: multipartBody))
                return apiResponse
            .compactMap{response in
                EntityResult.authorizedEntity(response.response)
            }
            .eraseToAnyPublisher()
        }
    
    func getRelationshipEntities(serverURL: String, cookie: String, relatedEntityIds: [String]) -> AnyPublisher<[UwaziRelationshipList], APIError> {
        let apiResponse: APIResponse<UwaziRelationshipDTO> = getAPIResponse(endpoint: API.getRelationshipEntities(serverURL:serverURL, cookie:cookie))
        let shouldFetchAllTemplates = relatedEntityIds.contains { $0.isEmpty }

        return apiResponse
            .compactMap{$0.response}
            .compactMap { dto in
                return dto.rows?
                    .filter{ $0.type == UwaziEntityMetadataKeys.template }
                    .filter { relationship in
                        shouldFetchAllTemplates || relatedEntityIds.contains(where: { $0 == relationship.id })
                    }
                    .compactMap{ $0.toDomain() as? UwaziRelationshipList }
            }
            .eraseToAnyPublisher()
    }
}

extension UwaziServerRepository {
    /// Return a collection of CollectedTemplate which is used to created after all the manpulation is done to prepare the template data for storage
    /// - Parameters:
    ///   - server: Server Object to get the information about the Uwazi server
    /// - Returns: Collection of CollectedTemplate
    func handleTemplate(server: UwaziServer) -> AnyPublisher<[UwaziTemplateRow], APIError> {
        guard let serverURL = server.url else {
            return Fail(error: APIError.unexpectedResponse).eraseToAnyPublisher()
        }
        let cookie = server.cookie ?? ""
        let getTemplate = UwaziServerRepository().getTemplate(serverURL: serverURL, cookieList: cookie)
        let getSetting = UwaziServerRepository().getSettings(serverURL: serverURL, cookieList: cookie)
        let getDictionary = UwaziServerRepository().getDictionaries(serverURL: serverURL, cookieList: cookie)
        let getTranslation = UwaziServerRepository().getTranslations(serverURL: serverURL, cookieList: cookie)

        return Publishers.Zip4(
            getTemplate,
            getSetting,
            getDictionary,
            getTranslation
        )
        .tryMap({ (templateResult, settings, dictionary, translationResult) in
            let templates = templateResult.rows
            let translations = translationResult.rows
            let dictionaryRows = dictionary.rows
            let settings: UwaziSettingDTO = settings

            // Maps the options to the property of the template
            self.handleMapping(templates, dictionaryRows)
            // Check whether the server instance is public and if public then only use the whitelisted templates are added to resultTemplates
            let resultTemplates = self.getAllowedTemplates(server: server, settings: settings, templates: templates)
            self.translate(locale: server.locale ?? "", resultTemplates: resultTemplates, translations: translations)
            return resultTemplates.compactMap({$0.toDomain() as? UwaziTemplateRow})
        })
        .mapError{$0 as! APIError}
        .eraseToAnyPublisher()
    }

    fileprivate func getAllowedTemplates(server: UwaziServer, settings: UwaziSettingDTO, templates: [UwaziTemplateRowDTO]?) -> [UwaziTemplateRowDTO] {
        // Check whether the server instance is public and if public then only use the whitelisted templates are added to resultTemplates
        var tempTemplates: [UwaziTemplateRowDTO] = []
        if !self.isPublic(server: server) {
            tempTemplates = templates ?? []
        } else {
            let allowedPublicTemplates = settings.allowedPublicTemplates ?? []
            if !allowedPublicTemplates.isEmpty {
                templates?.forEach { row in
                    allowedPublicTemplates.forEach { id in
                        if row.id == id {
                            tempTemplates.append(row)
                        }
                    }
                }
            }
        }
        return tempTemplates
    }

    fileprivate func isPublic(server: UwaziServer) -> Bool {
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

    fileprivate func translate(locale: String, resultTemplates: [UwaziTemplateRowDTO], translations: [UwaziTranslationRowDTO]?) {
        resultTemplates.forEach { template in
            // Get only the translations based on the language that user selected
            let filteredTranslations = translations?.filter{$0.locale == locale}
            filteredTranslations?.first?.contexts?.forEach{ context in
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
        case checkURL(serverURL: String, cookie: String)
        case getLanguage(serverURL: String, cookie: String)
        case twoFactorAuthentication((username: String,
                                      password: String,
                                      token: String,
                                      serverURL: String))
        case getTemplate(serverURL: String, cookieList:String)
        case getSetting(serverURL: String, cookieList:String)
        case getDictionary(serverURL: String, cookieList:String)
        case getTranslations(serverURL: String, cookieList:String)
        case submitEntity(serverURL: String, cookie: String, multipartHeader: String, multipartBody: Data)
        case submitPublicEntity(serverURL: String, cookie: String, multipartHeader: String, multipartBody: Data)
        case getRelationshipEntities(serverURL: String, cookie: String)
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
        case .getTemplate,.getSetting, .getDictionary, .getTranslations, .submitEntity, .submitPublicEntity, .getRelationshipEntities:
            return nil
        }
    }

    var headers: [String: String]? {
        switch self {
        case .login, .getProjetDetails, .twoFactorAuthentication:
            return [HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        case .getTemplate(_,let cookieList), .getSetting(_,let cookieList), .getDictionary(_,let cookieList), .getTranslations(_,let cookieList), .checkURL(_, let cookieList), .getLanguage(_, let cookieList), .getRelationshipEntities(serverURL: _, let cookieList):
            return [HTTPHeaderField.cookie.rawValue: cookieList,
                    HTTPHeaderField.contentType.rawValue : ContentType.json.rawValue]
        case .submitEntity(_, let cookie, _, _):
            return [HTTPHeaderField.cookie.rawValue: cookie,
                    HTTPHeaderField.xRequestedWith.rawValue: XRequestedWithValue.xmlHttp.rawValue,
                    HTTPHeaderField.contentType.rawValue : ContentType.data.rawValue ]
        case .submitPublicEntity(_, let cookie, _, _):
            return [HTTPHeaderField.cookie.rawValue: cookie,
                    HTTPHeaderField.xRequestedWith.rawValue: XRequestedWithValue.xmlHttp.rawValue,
                    HTTPHeaderField.contentType.rawValue: ContentType.data.rawValue,
                    HTTPHeaderField.ByPassCaptchaHeader.rawValue: "true"
            ]
        }
    }
    
    var encoding: Encoding {
        switch self {
        case .submitEntity, .submitPublicEntity:
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
        case .checkURL,
            .getLanguage,
            .getTemplate,
            .getSetting,
            .getDictionary,
            .getTranslations,
            .submitEntity(_, _, _, _),
            .submitPublicEntity,
            .getRelationshipEntities:
            return nil
        }
    }
    
    var multipartBody: Data? {
        switch self {
        case .submitEntity(_, _, _, let multipartBody), .submitPublicEntity(_, _, _, let multipartBody):
            return multipartBody
        default:
            return nil
        }
    }

    var multipartHeader: String? {
        switch self {
        case .submitEntity(_, _, let multipartHeader, _), .submitPublicEntity(_, _, let multipartHeader, _):
            return multipartHeader
        default:
            return nil
        }
    }
    var baseURL: String {
        switch self {
        case .login((_, _, let serverURL)), .twoFactorAuthentication((_,_,_, let serverURL)):
            return serverURL
        case .getProjetDetails((let projectURL, _)):
            return projectURL
        case .checkURL(serverURL: let serverURL, _) ,.getLanguage(serverURL: let serverURL, _):
            return serverURL
        case .getTemplate(serverURL: let serverURL, cookieList: _):
            return serverURL
        case .getSetting(serverURL: let serverURL, cookieList: _), .getDictionary(serverURL: let serverURL, cookieList: _),.getTranslations(serverURL: let serverURL, cookieList: _), .submitEntity(serverURL: let serverURL, _, _, _), .submitPublicEntity(let serverURL, _, _, _), .getRelationshipEntities(let serverURL, _):
            return serverURL
        }
    }

    var path: String? {
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
        case .submitPublicEntity:
            return "/api/public"
        case .getRelationshipEntities:
            return "/api/thesauris"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .login, .twoFactorAuthentication, .submitEntity, .submitPublicEntity:
            return HTTPMethod.post
        case .getProjetDetails(_):
            return HTTPMethod.get
        case .checkURL, .getLanguage, .getSetting, .getTemplate,.getDictionary,.getTranslations, .getRelationshipEntities:
            return HTTPMethod.get
        }
    }
}
