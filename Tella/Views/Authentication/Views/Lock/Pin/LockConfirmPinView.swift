//
//  LockConfirmPinView.swift
//  Tella
//
//  
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockConfirmPinView: View {
    
    @EnvironmentObject private var appViewState: AppViewState
    @ObservedObject var viewModel : LockViewModel
    @State var shouldShowErrorMessage : Bool = false
    
    var body: some View {
        
        CustomPinView(lockViewData: LockConfirmPinData(),
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

struct LockConfirmPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockConfirmPinView(viewModel: LockViewModel()).environmentObject(AppViewState())
    }
}
