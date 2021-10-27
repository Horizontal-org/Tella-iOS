//
//  LockViewModel.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

class LockViewModel: ObservableObject {
    
    @Published var password : String = ""
    @Published var confirmPassword : String = ""
    
    private var savedString : String?
    
    var shouldShowErrorMessage : Bool {
        return password != confirmPassword
    }
    @Published var shouldShowUnlockError : Bool = false

    func login() {
        let privateKey = CryptoManager.shared.recoverKey(.PRIVATE, password: password)
         shouldShowUnlockError = privateKey == nil
    }
}
