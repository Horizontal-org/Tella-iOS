//
//  UwaziServerViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 4/30/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
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
    @Published var selectedLanguage: UwaziLanguageRow?
    private var cancellableLogin: Cancellable? = nil
    private var cancellableAuthenticationCode: Cancellable? = nil
    var subscribers = Set<AnyCancellable>()

    var currentServer : UwaziServer?
    var token: String?
    var setting: UwaziCheckURL?
    var cookie: String?

    init(mainAppModel : MainAppModel, currentServer: UwaziServer?) {

        self.mainAppModel = mainAppModel
        self.currentServer = currentServer

        cancellableLogin = $validUsername.combineLatest($validPassword).sink(receiveValue: { validUsername, validPassword  in
            self.validCredentials = validUsername && validPassword
        })
        cancellableAuthenticationCode = $validCode.sink(receiveValue: { validCode in
            self.validAuthenticationCode = validCode
        })
    }

    func handleServerAction() {
        if currentServer != nil {
            updateServer()
        } else {
            addServer()
        }
    }

    func addServer() {
        let server = UwaziServer(name: setting?.siteName,
                                 serverURL: serverURL.getBaseURL(),
                                 username: username,
                                 password: password,
                                 accessToken: self.token,
                                 locale: selectedLanguage?.locale
        )
        debugLog(server)
        guard let id = mainAppModel.vaultManager.tellaData?.addUwaziServer(server: server) else { return }
        server.id = id
        self.currentServer = server
    }
    
    func updateServer() {
        guard let currentServer = currentServer, let currentServerId = currentServer.id else { return }
        let server = UwaziServer(id: currentServerId,
                                 name: setting?.siteName,
                                 serverURL: serverURL.getBaseURL(),
                                 username: username,
                                 password: password,
                                 accessToken: self.token,
                                 locale: selectedLanguage?.locale)


        guard let id = mainAppModel.vaultManager.tellaData?.updateUwaziServer(server: server) else { return }
        server.id = id
    }

    // MARK: - Get Language API Call Methods
    func getLanguage() {
        isLoading = true
        guard let baseURL = serverURL.getBaseURL() else { return }
        UwaziServerRepository().getLanguage(serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.handleCompletionForGetLanguage(completion)
            }, receiveValue: { wrapper in
                self.handleRecieveValueForGetLanguage(wrapper)
            }).store(in: &subscribers)
    }

    fileprivate func handleCompletionForGetLanguage(_ completion: Subscribers.Completion<APIError>) {
        self.isLoading = false
        switch completion {
        case .finished:
            debugLog("Finished")
            // TODO: Handle this error
        case .failure(let error):
            debugLog(error)
            switch error {
            case .noInternetConnection:
                Toast.displayToast(message: error.errorDescription ?? error.localizedDescription)
            default:
                break
            }
            self.isLoading = false
        }
    }

    fileprivate func handleRecieveValueForGetLanguage(_ wrapper: UwaziLanguage) {
        self.isLoading = false
        self.languages.append(contentsOf: wrapper.rows ?? [])
        if let server = self.currentServer {
            let locale = server.locale
            self.selectedLanguage = self.languages.compactMap{$0}.first(where: {$0.locale == locale})
        }
        self.showNextSuccessLoginView = true
    }


    // MARK: - Check URL API Call Methods
    func checkURL() {
        self.isLoading = true
        guard let baseURL = serverURL.getBaseURL() else { return }
        UwaziServerRepository().checkServerURL(serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.handleCompletionForCheckURL(completion)
            }, receiveValue: { wrapper in
                self.handleRecieveValueForCheckURL(wrapper)
            }).store(in: &subscribers)
    }

    fileprivate func handleCompletionForCheckURL(_ completion: Subscribers.Completion<APIError>) {
        self.isLoading = false
        switch completion {
        case .finished:
            debugLog("Finished")
            // TODO: handle this error
        case .failure(let error):
            switch error {
            case .noInternetConnection:
                Toast.displayToast(message: error.errorDescription ?? error.localizedDescription)
            default:
                debugLog(error)
                urlErrorMessage = error.errorDescription ?? error.localizedDescription
                shouldShowURLError = true
            }
        }
    }


    fileprivate func handleRecieveValueForCheckURL(_ wrapper: UwaziCheckURL) {
        self.setting = wrapper
        debugLog("Finished")
        self.isLoading = false
        self.isPublicInstance = true
    }
    
    // MARK: - Login API Call Methods
    func login() {
        guard let baseURL = serverURL.getBaseURL() else { return }

        isLoading = true

        UwaziServerRepository().login(username: username, password: password, serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.handleCompletionForLogin(completion)
                },
                receiveValue: { result in
                    self.handleReceiveValueForLogin(result)
                }
            )
            .store(in: &subscribers)
    }

    fileprivate func handleCompletionForLogin(_ completion: Subscribers.Completion<APIError>) {
        switch completion {
        case .failure(let error):
            switch error {
            case .invalidURL, .unexpectedResponse, .badServer:
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
                    self.loginErrorMessage = error.errorDescription ?? error.localizedDescription
                }
            case .noInternetConnection:
                Toast.displayToast(message: error.errorDescription ?? error.localizedDescription)
            }
        case .finished:
            self.shouldShowLoginError = false
            self.loginErrorMessage = ""
            break
        }
        self.isLoading = false
    }

    fileprivate func handleReceiveValueForLogin(_ result: String?) {
        self.isLoading = false
        if let result = result {
            self.token = result
            self.showNextLanguageSelectionView = true
        } else {
            self.shouldShowLoginError = true
            // TODO: More appropiate message here
            self.loginErrorMessage = "Something went wrong!!"
        }
    }



    // MARK: - 2FA API Call Methods
    func twoFactorAuthentication() {

        guard let baseURL = serverURL.getBaseURL() else { return }

        isLoading = true

        UwaziServerRepository().twoFactorAuthentication(username: username, password: password, token: code, serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.handleCompletionFor2FA(completion)
                },
                receiveValue: { result in
                    self.handleReceiveValueForLogin(result)
                }
            )
            .store(in: &subscribers)
    }
    fileprivate func handleCompletionFor2FA(_ completion: Subscribers.Completion<APIError>) {
        switch completion {
        case .failure(let error):
            switch error {
            case .invalidURL, .unexpectedResponse, .badServer:
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
            case .noInternetConnection:
                Toast.displayToast(message: error.errorDescription ?? error.localizedDescription)
            }
            self.shouldShowAuthenticationError = true
        case .finished:
            self.shouldShowAuthenticationError = false
            self.codeErrorMessage = ""
            break
        }
        self.isLoading = false
    }

    func fillUwaziServer() {
        guard let server = self.currentServer else { return }
        self.serverURL = server.url ?? ""
        // To Avoid the animation of textfield in login view
        self.username = ""
        self.username = ""

    }

    func fillUwaziCredentials() {
        guard let server = self.currentServer else { return }
        self.username = server.username ?? ""
        self.password = server.password ?? ""
    }
}

