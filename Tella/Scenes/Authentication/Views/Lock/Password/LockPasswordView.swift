//
//  LockPasswordView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockPasswordView: View {
    
    @EnvironmentObject var lockViewModel: LockViewModel

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
        LockPasswordView()
    }
}
