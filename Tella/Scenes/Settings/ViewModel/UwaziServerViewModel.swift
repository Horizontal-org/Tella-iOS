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
    @Published var name : String?
    @Published var projectURL : String = "https://"
    @Published var username : String = ""
    @Published var password : String = ""
    @Published var code: String = ""
    @Published var activatedMetadata : Bool = false
    @Published var backgroundUpload : Bool = false
    @Published var autoUpload : Bool = false
    @Published var autoDelete : Bool = false


    // Add URL
    @Published var validURL : Bool = false
    @Published var shouldShowURLError : Bool = false
    @Published var urlErrorMessage : String = ""

    // Login
    @Published var validUsername : Bool = false
    @Published var validPassword : Bool = false
    @Published var validCode: Bool = false
    @Published var validCredentials : Bool = false
    @Published var validAuthenticationCode: Bool = false
    @Published var shouldShowLoginError : Bool = false
    @Published var shouldShowAuthenticationError: Bool = false
    @Published var loginErrorMessage : String = ""
    @Published var codeErrorMessage: String = ""
    @Published var isLoading : Bool = false
    @Published var showNextSuccessLoginView : Bool = false

    private var cancellableLogin: Cancellable? = nil
    private var cancellableAuthenticationCode: Cancellable? = nil
    var subscribers = Set<AnyCancellable>()

    var currentServer : Server?

    var isAutoUploadServerExist: Bool {
        return mainAppModel.vaultManager.tellaData.getAutoUploadServer() != nil && autoUpload == false
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

    func addServer(token: String, project: ProjectAPI) {

        let server = Server(name: project.name,
                            serverURL: projectURL.getBaseURL(),
                            username: username,
                            password: password,
                            accessToken: token,
                            activatedMetadata: activatedMetadata,
                            backgroundUpload: backgroundUpload,
                            projectId: project.id,
                            slug: project.slug,
                            autoUpload: autoUpload,
                            autoDelete: autoDelete)

        do {
            let id = try mainAppModel.vaultManager.tellaData.addServer(server: server)
            server.id = id

            self.currentServer = server

        } catch {

        }
    }

    func updateServer() {
        do {

            guard let currentServer = self.currentServer else { return  }
            currentServer.backgroundUpload = backgroundUpload
            currentServer.activatedMetadata = activatedMetadata
            currentServer.autoUpload = autoUpload
            currentServer.autoDelete = autoDelete

            _ = try mainAppModel.vaultManager.tellaData.updateServer(server: currentServer)

        } catch {

        }
    }

    func checkURL() {

        isLoading = true




        //        API.Request.Server.publisher(serverURL: url)
        //            .receive(on: DispatchQueue.main)
        //            .sink(
        //                receiveCompletion: { completion in
        //                    self.isLoading = false
        //
        //                    switch completion {
        //                    case .failure(let error):
        //
        //                        if error.code == 400 {
        //                            self.shouldShowURLError = false
        //                            self.urlErrorMessage = ""
        //                            self.showNextLoginView = true
        //                        } else {
        //                            self.shouldShowURLError = true
        //                            self.urlErrorMessage = error.message
        //                        }
        //
        //                    case .finished:
        //                        break
        //                    }
        //                },
        //                receiveValue: { wrapper in
        //                }
        //            )
        //            .store(in: &subscribers)
    }

    func login() {

        guard let baseURL = projectURL.getBaseURL() else { return }

        isLoading = true

        ServerRepository().login(username: username, password: password, serverURL: baseURL)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in

                    switch completion {
                    case .failure(let error):
                        self.shouldShowLoginError = true
                        self.loginErrorMessage = error.errorDescription ?? ""
                        self.isLoading = false

                    case .finished:
                        //                        self.shouldShowLoginError = false
                        //                        self.loginErrorMessage = ""
                        //                        self.showNextSuccessLoginView = true
                        break

                    }
                },
                receiveValue: { result in
                    //

                    self.getProjetSlug(token: result.accessToken)

                }
            )
            .store(in: &subscribers)
    }


    func getProjetSlug(token: String) {

        //        isLoading = true

        ServerRepository().getProjetDetails(projectURL: projectURL, token: token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoading = false

                    switch completion {
                    case .failure(let error):
                        self.shouldShowLoginError = true
                        self.loginErrorMessage = error.errorDescription ?? ""
                    case .finished:
                        self.shouldShowLoginError = false
                        self.loginErrorMessage = ""
                        self.showNextSuccessLoginView = true
                    }
                },
                receiveValue: { project in
                    self.addServer(token: token,project: project)
                }
            )
            .store(in: &subscribers)

    }


    func fillReportVM() {
        if let server = self.currentServer {
            name =  server.name ?? ""
            projectURL = server.url ?? ""
            username = server.username ?? ""
            password = server.password ?? ""
            activatedMetadata = server.activatedMetadata ?? false
            backgroundUpload = server.backgroundUpload ?? false
            autoUpload = server.autoUpload ?? false
            autoDelete = server.autoDelete ?? false
        }
    }
}

