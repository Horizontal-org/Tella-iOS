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
    
    var shouldShowError : Bool {
        return password != confirmPassword
    }
    
}
