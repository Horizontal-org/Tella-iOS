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
    @State var message = Localizable.Lock.pinFirstMessage
    
    var body: some View {
        
        CustomPinView(nextButtonAction: .destination,
                      fieldContent: $lockViewModel.password,
                      shouldShowErrorMessage: .constant(false),
                      message: $message,
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


