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
    @State var shouldShowError : Bool = false
    
    var body: some View {

        CustomPinView(lockViewData: LockConfirmPinData(),
                     nextButtonAction: .action,
                     fieldContent: $viewModel.confirmPassword,
                     shouldShowError: $shouldShowError,
                     destination: EmptyView()) {
            
            if viewModel.shouldShowError {
                shouldShowError = true
            } else {
                self.appViewState.resetToMain()
            }
        }
    }
}

struct LockConfirmPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockConfirmPinView(viewModel: LockViewModel()).environmentObject(AppViewState())
    }
}
