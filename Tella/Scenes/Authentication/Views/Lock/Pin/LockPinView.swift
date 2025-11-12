//
//  LockPinView.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct LockPinView: View {
    
    @ObservedObject var lockViewModel: LockViewModel
    
    var body: some View {
        
        CustomPinView(shouldEnableBackButton: false,
                      lockViewData: LockPinData(),
                      nextButtonAction: .destination,
                      fieldContent: $lockViewModel.password,
                      shouldShowErrorMessage: .constant(false),
                      destination: LockConfirmPinView(lockViewModel: lockViewModel))
        .onAppear {
            lockViewModel.initLockData()
        }
    }
}

struct LockPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockPinView(lockViewModel: LockViewModel.stub())
    }
}


