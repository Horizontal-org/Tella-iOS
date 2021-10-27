//
//  ConfirmLPasswordView.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ConfirmLockPasswordView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    @ObservedObject var viewModel : LockViewModel
    @State var shouldShowErrorMessage : Bool = false
    
    var body: some View {
        
        PasswordView(lockViewData: LockConfirmPasswordData(),
                     nextButtonAction: .action,
                     fieldContent: $viewModel.confirmPassword,
                     shouldShowErrorMessage: $shouldShowErrorMessage,
                     destination: EmptyView()) {
            
            if viewModel.shouldShowErrorMessage {
                shouldShowErrorMessage = true
            } else {
                do {

                    try CryptoManager.shared.initKeys(.PASSWORD, password: viewModel.password)
                    self.appViewState.resetToMain()
                }catch {

                }
            }
        }
    }
}

struct ConfirmLPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmLockPasswordView(viewModel: LockViewModel())
    }
}
