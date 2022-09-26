//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI


class ServersViewModel: ObservableObject {
    
    var mainAppModel : MainAppModel
    
    @Published var serverURL : String = "https://"
    
    @Published var validURL : Bool = false
    @Published var shouldShowError : Bool = true
    
    @Published var errorMessage : String = ""
    
    
    
    
    @Published var username : String = ""
    @Published var password : String = ""
    
    @Published var validUsername : Bool = false
    @Published var validPassword : Bool = false
    
    @Published var shouldShowLoginError : Bool = true
    
    @Published var loginErrorMessage : String = ""
    
    @Published var rootLinkIsActive : Bool = false
    
    @Published var servers : [Server]?
    
    var selectedServer : Server?

    
    func checkURL() { // To test
        
//        shouldShowError = serverURL != "https://"
//        
//        if serverURL != "https://" {
//            errorMessage = "Error: The server URL is incorrect"
//            validURL = false
//        } else {
//            errorMessage = ""
//            validURL = true
//        }
    }
    
    func login() { // To test
        
        //        shouldShowLoginError = (username != "dhekra" && password != "password")
        //
        //        if username != "dhekra" && password != "password" {
        //            loginErrorMessage = "Error: The server URL is incorrect"
        //            validUsername = false
        //            validPassword = false
        //        } else {
        //            loginErrorMessage = ""
        //            validUsername = true
        //            validPassword = true
        //        }
        
    }
    
    init(mainAppModel : MainAppModel) {
        self.mainAppModel = mainAppModel
        servers = mainAppModel.vaultManager.tellaData.getServers()
    }
    
    func addServer()  {
        
        let serverToAdd = Server(name: "Name", url: serverURL, username: username, password: password)
        
        do {
            let id = try mainAppModel.vaultManager.tellaData.addServer(server: Server(name: "Name", url: serverURL, username: username, password: password))
            serverToAdd.id = id
            self.servers?.append(serverToAdd)
        } catch {
            
        }
    }
}
