//
//  UwaziServerViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 4/30/23.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import Foundation
import Combine

class UwaziServerViewModel: ObservableObject {
    var mainAppModel : MainAppModel

    // Server propreties
    @Published var serverURL : String = "https://"

    
    @Published var name : String?
    @Published var username : String = ""
    @Published var password : String = ""
    @Published var activatedMetadata : Bool = false
    @Published var backgroundUpload : Bool = false
    @Published var autoUpload : Bool = false
    @Published var autoDelete : Bool = false


    // Add URL
    @Published var validURL : Bool = false
    @Published var shouldShowURLError : Bool = false
    @Published var urlErrorMessage : String = ""
    @Published var isPublicInstance: Bool?

    // Login
    @Published var validUsername : Bool = false
    @Published var validPassword : Bool = false
    @Published var validCode: Bool = false
    @Published var validCredentials : Bool = false
    @Published var shouldShowLoginError : Bool = false
    @Published var loginErrorMessage : String = ""
    @Published var isLoading : Bool = false
    @Published var showNextSuccessLoginView : Bool = false
    @Published var showNextLanguageSelectionView: Bool = false
    @Published var showNext2FAView: Bool = false

    // Authentication
    @Published var validAuthenticationCode: Bool = false
    @Published var shouldShowAuthenticationError: Bool = false
    @Published var code: String = ""
    @Published var codeErrorMessage: String = ""
    @Published var showLanguageSelectionView: Bool = false

    // Language
    @Published var languages: [UwaziLanguageRow] = []
    @Published var selectedLanguage: UwaziLanguageAPI?
    private var cancellableLogin: Cancellable? = nil
    private var cancellableAuthenticationCode: Cancellable? = nil
    var subscribers = Set<AnyCancellable>()

    var currentServer : Server?
    var token: String?
    var setting: UwaziCheckURLResult?

    var isAutoUploadServerExist: Bool {
        return mainAppModel.vaultManager.tellaData?.getAutoUploadServer() != nil && autoUpload == false
    }

    init(mainAppModel : MainAppModel, currentServer: Server?) {

        self.mainAppModel = mainAppModel
        self.currentServer = currentServer

        cancellableLogin = $validUsername.combineLatest($validPassword).sink(receiveValue: { validUsername, validPassword  in
            self.validCredentials = validUsername && validPassword
        })
        cancellableAuthenticationCode = $validCode.sink(receiveValue: { validCode in
            self.validAuthenticationCode = validCode
        })
        fillReportVM()

    }
    func handleServerAction() {
        if currentServer != nil {
            updateServer()
        } else {
            addServer()
        }
    }
    func addServer() {
        let server = Server(name: setting?.siteName,
                            serverURL: serverURL.getBaseURL(),
                            username: username,
                            password: password,
                            accessToken: self.token,
                            activatedMetadata: activatedMetadata,
                            backgroundUpload: backgroundUpload,
                            projectId: setting?.id,
                            slug: "",
                            autoUpload: autoUpload,
                            autoDelete: autoDelete,
                            serverType: .uwazi
        )
        do {
            dump(server)
            guard let id = try mainAppModel.vaultManager.tellaData?.addServer(server: server) else { return }
            server.id = id
            self.addUwaziLocaleFor(serverId: id)
            self.currentServer = server

        } catch {

        }
    }
    func updateServer() {
        guard let currentServer = currentServer, let currentServerId = currentServer.id else { return }
        let server = Server(id: currentServerId,
            name: setting?.siteName,
                            serverURL: serverURL.getBaseURL(),
                            username: username,
                            password: password,
                            accessToken: self.token,
                            activatedMetadata: activatedMetadata,
                            backgroundUpload: backgroundUpload,
                            projectId: setting?.id,
                            slug: "",
                            autoUpload: autoUpload,
                            autoDelete: autoDelete)

        do {
            let id = try mainAppModel.vaultManager.tellaData?.updateServer(server: server)
            server.id = id
            updateUwaziLocaleFor(serverId: currentServerId)
        } catch {

        }
    }
    func addUwaziLocaleFor(serverId: Int) {
        do {
            guard let locale = self.selectedLanguage?.locale else { return }
            _ = try mainAppModel.vaultManager.tellaData?.database?.addUwaziLocaleWith(locale: UwaziLocale(locale: locale, serverId: serverId))
        } catch let error {
            debugLog(error)
        }
    }
    func updateUwaziLocaleFor(serverId: Int) {
        do {
            let selectedlocale = try mainAppModel.vaultManager.tellaData?.database?.getUwaziLocaleWith(serverId: serverId)
            guard let localeId = selectedlocale?.id, let locale = selectedLanguage?.locale else { return }
            if selectedlocale?.locale != locale {
                _ = try mainAppModel.vaultManager.tellaData?.database?.updateLocale(localeId: localeId, locale: locale)
            }
        } catch let error {
            debugLog(error)
        }
    }

    func getLanguage() {
        isLoading = true
        guard let baseURL = serverURL.getBaseURL() else { return }
        UwaziServerRepository().getLanguage(serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false

                switch completion {

                case .finished:
                    debugLog("Finished")
                    // TODO: Handle this error
                case .failure(let error):
                    debugLog(error)
                    self.isLoading = false
                }

            }, receiveValue: { wrapper in
                debugLog("Finished")
                self.isLoading = false
                self.languages.append(contentsOf: wrapper.rows ?? [])
                if let server = self.currentServer, let id = server.id {
                    let locale = try? self.mainAppModel.vaultManager.tellaData?.database?.getUwaziLocaleWith(serverId: id)
                    self.selectedLanguage = self.languages.map{$0.toDomain() as? UwaziLanguageAPI}.compactMap{$0}.first(where: {$0.locale == locale?.locale})
                }
                self.showNextSuccessLoginView = true
            }).store(in: &subscribers)
    }

    func checkURL() {

        isLoading = true
        guard let baseURL = serverURL.getBaseURL() else { return }
        UwaziServerRepository().checkServerURL(serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false

                switch completion {

                case .finished:
                    debugLog("Finished")
                    // TODO: handle this error
                case .failure(let error):
                    debugLog(error)
                    self.isPublicInstance = false
                }
            }, receiveValue: { wrapper in
                self.setting = wrapper
                debugLog("Finished")
                self.isLoading = false
                self.isPublicInstance = true
            }).store(in: &subscribers)
    }

    func login() {
        guard let baseURL = serverURL.getBaseURL() else { return }

        isLoading = true

        UwaziServerRepository().login(username: username, password: password, serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in

                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .invalidURL, .unexpectedResponse:
                            self.shouldShowLoginError = true
                            self.loginErrorMessage = error.errorDescription ?? ""
                        case .httpCode(let code):
                            // if the status code is 401 then username or password is not matching
                            // if the status code is 409 then 2FA is needed
                            let httpError = HTTPErrorCodes(rawValue: code) ?? .unknown
                            switch httpError {
                            case .need2FA:
                                self.showNext2FAView = true
                            default:
                                self.shouldShowLoginError = true
                                self.loginErrorMessage = error.localizedDescription
                            }
                        }
                    case .finished:
                        self.shouldShowLoginError = false
                        self.loginErrorMessage = ""
                        break

                    }
                    self.isLoading = false
                },
                receiveValue: { result in
                    self.isLoading = false
                    if result.0.success ?? false {
                        self.showNextLanguageSelectionView = true
                        if let token = result.1 {
                            self.token = token
                        }
                    }
                }
            )
            .store(in: &subscribers)
    }

    func twoFactorAuthentication() {

        guard let baseURL = serverURL.getBaseURL() else { return }

        isLoading = true

        UwaziServerRepository().twoFactorAuthentication(username: username, password: password, token: code, serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in

                    switch completion {
                    case .failure(let error):
                        switch error {
                        case .invalidURL, .unexpectedResponse:
                            self.codeErrorMessage = error.errorDescription ?? ""
                        case .httpCode(let code):
                            // if the status code is 401 then the 2FA code is incorrect
                            let httpError = HTTPErrorCodes(rawValue: code) ?? .unknown
                            switch httpError {
                            case .unauthorized:
                                self.codeErrorMessage = "Two-factor authentication failed."
                            default:
                                self.codeErrorMessage = error.errorDescription ?? ""
                            }
                        }
                        self.shouldShowAuthenticationError = true
                    case .finished:
                        self.shouldShowAuthenticationError = false
                        self.codeErrorMessage = ""
                        break
                    }
                    self.isLoading = false
                },
                receiveValue: { result in
                    self.isLoading = false
                    if result.0.success ?? false {
                        self.showNextLanguageSelectionView = true
                        if let token = result.1 {
                            self.token = token
                        }
                    }
                }
            )
            .store(in: &subscribers)
    }

    func fillReportVM() {
        if let server = self.currentServer {
            name =  server.name ?? ""
            serverURL = server.url ?? ""
            username = server.username ?? ""
            password = server.password ?? ""
            activatedMetadata = server.activatedMetadata ?? false
            backgroundUpload = server.backgroundUpload ?? false
            autoUpload = server.autoUpload ?? false
            autoDelete = server.autoDelete ?? false
        }
    }
}

