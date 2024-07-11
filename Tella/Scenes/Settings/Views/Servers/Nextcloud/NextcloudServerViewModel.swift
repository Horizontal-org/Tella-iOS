//
//  NextcloudServerViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

class NextcloudServerViewModel: ServerViewModel {
    
    private var nextcloudRepository: NextcloudRepository
    private var mainAppModel: MainAppModel
    var currentServer: NextcloudServer?
    
    var serverCreateFolderVM: ServerCreateFolderViewModel

    init(nextcloudRepository: NextcloudRepository = NextcloudRepository(),
         mainAppModel: MainAppModel,
         currentServer: NextcloudServer? = nil) {

        self.nextcloudRepository = nextcloudRepository
        self.mainAppModel = mainAppModel
        self.currentServer = currentServer
        //TODO: We should replace this with nextcloud attributes ('textFieldPlaceholderText', 'headerViewTitleText' and 'imageIconName' )
        self.serverCreateFolderVM = ServerCreateFolderViewModel(textFieldPlaceholderText: LocalizableSettings.GDriveCreatePersonalFolderPlaceholder.localized,
                                                                headerViewTitleText: LocalizableSettings.GDriveCreatePersonalFolderTitle.localized,
                                                                headerViewSubtitleText: LocalizableSettings.GDriveCreatePersonalFolderDesc.localized, imageIconName: "gdrive.icon")
        super.init()
        self.serverCreateFolderVM.createFolderAction = createNextCloudFolder

    }
    
    override func checkURL() {
        checkServerState = .loading
        Task { @MainActor in
            do {
                try await nextcloudRepository.checkServer(serverUrl: serverURL)
                checkServerState = .loaded(true)
            }
            catch let error{
                checkServerState = .error(error.localizedDescription)
            }
        }
    }
    
    override func login() {
        loginState = .loading
        Task { @MainActor in
            do {
                try await nextcloudRepository.login(serverUrl: serverURL, username: username, password: password)
                addServer()
                loginState = .loaded(true)
            }
            catch let error{
                loginState = .error(error.localizedDescription)
            }
        }
    }
    
    func addServer() {
        let server = NextcloudServer(serverURL: serverURL, username: username, password: password)
        let serverID = mainAppModel.tellaData?.addNextcloudServer(server: server)
        
        guard let serverID else {
            return
        }
        server.id = serverID
        self.currentServer = server
    }
    
    func updateServer() {
//        guard let currentServer = self.currentServer as? NextcloudServer  else { return  }
//        currentServer.userId = userId
//        currentServer.rootFolder = rootFolder
//        mainAppModel.tellaData?.updateNextcloudServer(server: currentServer)
    }
    
    func createNextCloudFolder() {
        serverCreateFolderVM.createFolderState = .loading
        
        Task { @MainActor in
            do {
                try await nextcloudRepository.createFolder(serverUrl: serverURL, folderName: serverCreateFolderVM.folderName)
                //TODO: Saving server to database
                serverCreateFolderVM.createFolderState = .loaded(true)
            }
            catch let error{
                serverCreateFolderVM.createFolderState = .error(error.localizedDescription)
            }
        }
    }
}
