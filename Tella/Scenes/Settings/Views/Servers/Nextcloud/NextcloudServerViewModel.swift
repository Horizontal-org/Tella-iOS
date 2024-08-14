//
//  NextcloudServerViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//
import Combine
class NextcloudServerViewModel: ServerViewModel {
    
    private var nextcloudRepository: NextcloudRepository
    private var mainAppModel: MainAppModel
    var currentServer: NextcloudServer?
    
    var serverCreateFolderVM: ServerCreateFolderViewModel
    
    private var userId = ""
    init(nextcloudRepository: NextcloudRepository = NextcloudRepository(),
         mainAppModel: MainAppModel,
         currentServer: NextcloudServer? = nil,
         username:String? = nil) {
        
        self.nextcloudRepository = nextcloudRepository
        self.mainAppModel = mainAppModel
        self.currentServer = currentServer
        //TODO: We should replace this with nextcloud attributes ('textFieldPlaceholderText', 'headerViewTitleText' and 'imageIconName' )
        self.serverCreateFolderVM = ServerCreateFolderViewModel(textFieldPlaceholderText: LocalizableSettings.GDriveCreatePersonalFolderPlaceholder.localized,
                                                                headerViewTitleText: LocalizableSettings.GDriveCreatePersonalFolderTitle.localized,
                                                                headerViewSubtitleText: LocalizableSettings.GDriveCreatePersonalFolderDesc.localized, imageIconName: "nextcloud.icon")
        super.init()
        self.serverCreateFolderVM.createFolderAction = createNextCloudFolder
        
        // initialize server parameters
        if let serverURL = currentServer?.url {
            self.serverURL = serverURL
        }
        if let username {
            self.username = username
        }
    }
    
    override func checkURL() {
        checkServerState = .loading
        Task { @MainActor in
            do {
                try await nextcloudRepository.checkServer(serverUrl: serverURL)
                checkServerState = .loaded(true)
            }
            
            catch let ncError as APIError {
                switch ncError {
                case .noInternetConnection:
                    checkServerState = .error(ncError.errorDescription ?? "")
                    urlErrorMessage = ""
                    shouldShowURLError = false
                default:
                    urlErrorMessage = ncError.errorDescription ?? ""
                    shouldShowURLError = true
                    checkServerState = .error("")
                }
            }
        }
    }
    
    override func login() {
        loginState = .loading
        Task { @MainActor in
            do {
                let userId = try await nextcloudRepository.login(serverUrl: serverURL, username: username, password: password)
                self.userId = userId
                loginState = .loaded(true)
            }
            catch let ncError as APIError {
                switch ncError {
                case .noInternetConnection:
                    loginErrorMessage = ""
                    shouldShowLoginError = false
                    loginState = .error(ncError.errorDescription ?? "")
                default:
                    shouldShowLoginError = true
                    loginErrorMessage = ncError.errorDescription ?? ""
                    loginState = .error("")
                }
            }
        }
    }
    
    func addServer() {
        let server = NextcloudServer(serverURL: serverURL, username: username, password: password, userId: userId, rootFolder: serverCreateFolderVM.folderName)
        let serverID = mainAppModel.tellaData?.addNextcloudServer(server: server)
        
        guard let serverID else {
            return
        }
        server.id = serverID
        self.currentServer = server
    }
    
    func updateServer() {
        guard let currentServer = self.currentServer  else { return  }
        currentServer.password = password
        mainAppModel.tellaData?.updateNextcloudServer(server: currentServer)
    }
    
    func createNextCloudFolder() {
        serverCreateFolderVM.createFolderState = .loading
        
        Task { @MainActor in
            do {
                let server = NextcloudServer(serverURL: serverURL, username: username, password: password, userId: userId)
                
                let serverParameters = try NextcloudServerModel(server:server)
                
                try await nextcloudRepository.createFolder(folderName: serverCreateFolderVM.folderName,
                                                           server: serverParameters)
                addServer()
                serverCreateFolderVM.createFolderState = .loaded(true)
            }
            catch let ncError as APIError {
                switch ncError {
                case .noInternetConnection:
                    handleCreateFolderError(errorStateMessage: ncError.errorDescription ?? "")
                default:
                    handleCreateFolderError(errorMessage: ncError.errorDescription ?? "",
                                            errorStateMessage: "",
                                            shouldShowError: true)
                }
            } catch let ncError as RuntimeError {
                handleCreateFolderError(errorStateMessage: ncError.message)
            }
        }
    }
    
    private func handleCreateFolderError(errorMessage: String = "", errorStateMessage: String, shouldShowError:Bool = false ) {
        serverCreateFolderVM.createFolderState = .error(errorStateMessage)
        serverCreateFolderVM.errorMessage = errorMessage
        serverCreateFolderVM.shouldShowError = shouldShowError
    }
}
