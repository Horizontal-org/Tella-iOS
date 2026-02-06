//
//  UwaziServerViewModel.swift
//  Tella
//
//  Created by Robert Shrestha on 4/30/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine


class UwaziServerViewModel: ServerViewModel {
    var mainAppModel : MainAppModel

    @Published var name : String?
    @Published var isPublicInstance: Bool?

    // Login
    @Published var validCode: Bool = false
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
    private var cancellableAuthenticationCode: Cancellable? = nil
    var subscribers = Set<AnyCancellable>()

    var currentServer : UwaziServer?
    var token: String?
    var setting: UwaziCheckURL?
    var cookie: String?

    init(mainAppModel : MainAppModel,
         currentServer: UwaziServer? = nil,
         serversSourceView: ServersSourceView = .settings) {
        self.mainAppModel = mainAppModel
        self.currentServer = currentServer
        super.init(serversSourceView: serversSourceView)
        cancellableAuthenticationCode = $validCode.sink(receiveValue: { validCode in
            self.validAuthenticationCode = validCode
        })
    }

    func handleServerAction() {
        if currentServer != nil {
            updateServer()
        } else {
            self.isPublicInstance == true ? addServer() : checkURL()
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
        guard let id = mainAppModel.tellaData?.addUwaziServer(server: server) else { return }
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


        guard let id = mainAppModel.tellaData?.updateUwaziServer(server: server) else { return }
        server.id = id
    }

    // MARK: - Get Language API Call Methods
    func getLanguage() {
        isLoading = true
        guard let baseURL = serverURL.getBaseURL() else { return }
        let cookie = "connect.sid=\(self.token ?? "")"
        UwaziServerRepository().getLanguage(serverURL: baseURL, cookie: cookie)
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
                Toast.displayToast(message: error.errorMessage)
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
    override func checkURL() {
        self.isLoading = true
        guard let baseURL = serverURL.getBaseURL() else { return }
        let cookie = "connect.sid=\(self.token ?? "")"
        UwaziServerRepository().checkServerURL(serverURL: baseURL, cookie: cookie)
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
                Toast.displayToast(message: error.errorMessage)
            case .httpCode(HTTPErrorCodes.unauthorized.rawValue):
                handlePrivateInstance()
            default:
                debugLog(error)
                urlErrorMessage = error.errorMessage
                shouldShowURLError = true
            }
        }
    }

    fileprivate func handlePrivateInstance() {
        self.isLoading = false
        self.isPublicInstance = false
    }

    fileprivate func handleRecieveValueForCheckURL(_ result: UwaziCheckURL) {
        guard let isPrivate = result.isPrivate else { return }
        
        self.setting = result
        self.isLoading = false
        
        if isPrivate {
            addServer()
        } else {
            self.isPublicInstance = true
        }
    }
    
    // MARK: - Login API Call Methods
    override func login() {
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
                self.loginErrorMessage = error.errorMessage
            case .httpCode(let code):
                // if the status code is 401 then username or password is not matching
                // if the status code is 409 then 2FA is needed
                let httpError = HTTPErrorCodes(rawValue: code) ?? .unknown
                switch httpError {
                case .conflict:
                    self.showNext2FAView = true
                default:
                    self.shouldShowLoginError = true
                    self.loginErrorMessage = error.errorMessage
                }
            case .noInternetConnection:
                Toast.displayToast(message: error.errorMessage)
            default:
                break
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
                self.codeErrorMessage = error.errorMessage
            case .httpCode(let code):
                // if the status code is 401 then the 2FA code is incorrect
                let httpError = HTTPErrorCodes(rawValue: code) ?? .unknown
                switch httpError {
                case .unauthorized:
                    self.codeErrorMessage = "Two-factor authentication failed."
                default:
                    self.codeErrorMessage = error.errorMessage
                }
            case .noInternetConnection:
                Toast.displayToast(message: error.errorMessage)
            default:
                break
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

extension UwaziServerViewModel {
    static func stub() -> UwaziServerViewModel {
        return UwaziServerViewModel(mainAppModel: MainAppModel.stub())
    }
}
