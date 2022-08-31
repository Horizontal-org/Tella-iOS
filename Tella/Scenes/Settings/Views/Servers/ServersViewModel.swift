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

    
    func checkURL() {
        
        shouldShowError = serverURL != "https://"
        
        if serverURL != "https://" {
            errorMessage = "Error: The server URL is incorrect"
            validURL = false
        } else {
            errorMessage = ""
            validURL = true
        }
            
    }

    
    init(mainAppModel : MainAppModel) {
        self.mainAppModel = mainAppModel
    }
}
