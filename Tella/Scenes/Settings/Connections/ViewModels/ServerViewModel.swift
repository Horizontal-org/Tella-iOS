//
//  ServerViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Combine

class ServerViewModel: ObservableObject {
    @Published var username : String = ""
    @Published var password : String = ""
    @Published var isLoading : Bool = false
    func checkURL() {}
    func login() {}
    // Server propreties
    @Published var serverURL : String = "https://"
    
    // Add URL
    @Published var validURL : Bool = false
    @Published var shouldShowURLError : Bool = false
    @Published var urlErrorMessage : String = ""
    // ServerCheck
    @Published var checkServerState: ViewModelState<Bool> = .loaded(false)
    
    // Login
    @Published var validUsername : Bool = false
    @Published var validPassword : Bool = false
    @Published var shouldShowLoginError : Bool = false
    @Published var validCredentials : Bool = false
    @Published var loginErrorMessage : String = ""
    @Published var showNextSuccessLoginView : Bool = false
    @Published var loginState: ViewModelState<Bool> = .loaded(false)
    
    var serversSourceView: ServersSourceView
    
    private var cancellable: Cancellable? = nil
    
    init(serversSourceView: ServersSourceView = .settings) {
        self.serversSourceView = serversSourceView
        validateCredentials()
    }
    
    private func validateCredentials() {
        cancellable = $validUsername.combineLatest($validPassword).sink(receiveValue: { validUsername, validPassword  in
            self.validCredentials = validUsername && validPassword
        })
    }
    
}
