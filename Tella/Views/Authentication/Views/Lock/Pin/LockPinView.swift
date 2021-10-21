//
//  LockPinView.swift
//  Tella
//
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockPinView: View {
    @StateObject var viewModel = LockViewModel()
    
    var body: some View {
        
        CustomPinView(lockViewData: LockPinData(),
                      nextButtonAction: .destination,
                      fieldContent: $viewModel.password,
                      shouldShowError: .constant(false),
                      destination: LockConfirmPinView(viewModel: viewModel))
    }
}

struct LockPinView_Previews: PreviewProvider {
    static var previews: some View {
        LockPinView()
    }
}


