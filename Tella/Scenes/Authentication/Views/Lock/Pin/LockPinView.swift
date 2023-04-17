//
//  LockPinView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockPinView: View {
    @EnvironmentObject var lockViewModel: LockViewModel

    var body: some View {
        
        CustomPinView(shouldEnableBackButton: false,
                      lockViewData: LockPinData(),
                      nextButtonAction: .destination,
                      fieldContent: $lockViewModel.password,
                      shouldShowErrorMessage: .constant(false),
                      destination: LockConfirmPinView().environmentObject(lockViewModel))
            .onAppear {
                lockViewModel.initLockData()

            }.navigationBarBackButtonHidden(true)

    }
}

struct LockPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockPinView()
    }
}


