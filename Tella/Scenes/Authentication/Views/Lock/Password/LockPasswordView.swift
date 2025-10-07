//
//  LockPasswordView.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct LockPasswordView: View {
    
    @ObservedObject var lockViewModel: LockViewModel
    
    var body: some View {
        PasswordView(shouldEnableBackButton: false,
                     lockViewData: LockPasswordData(),
                     nextButtonAction: .destination,
                     fieldContent: $lockViewModel.password,
                     shouldShowErrorMessage: .constant(false),
                     destination: ConfirmLockPasswordView().environmentObject(lockViewModel))
        .onAppear {
            lockViewModel.initLockData()
        }
    }
}

struct LockPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        LockPasswordView(lockViewModel: LockViewModel.stub())
    }
}
