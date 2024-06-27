//
//  ServerViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Combine

class ServerViewModel: ObservableObject {
    @Published var username : String = ""
    @Published var password : String = ""
    @Published var isLoading : Bool = false
    func checkURL() {}
    // Server propreties
    @Published var serverURL : String = "https://"

    // Add URL
    @Published var validURL : Bool = false
    @Published var shouldShowURLError : Bool = false
    @Published var urlErrorMessage : String = ""
}
