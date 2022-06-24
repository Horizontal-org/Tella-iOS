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
    
    @State var message = Localizable.Lock.lockPinSetBannerExpl

    var body: some View {
        CustomCalculatorView(value: $lockViewModel.calculatorValue,
                             result: $lockViewModel.password,
                             message: $message,
                             isValid: $lockViewModel.isValid,
                             operationArray: $lockViewModel.operationArray,
                             calculatorType: .lockCalculator, nextButtonAction: .destination,
                             destination: LockConfirmPinView())
        .onAppear {
            lockViewModel.initLockData()
        }
    }
}

struct LockPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockPinView()
    }
}
