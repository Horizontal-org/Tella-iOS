//
//  LockPasswordView.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LockPasswordView: View {
    
    @StateObject var viewModel = LockViewModel()

    var body: some View {
        PasswordView(lockViewData: LockPasswordData(),
                     nextButtonAction: .destination,
                     fieldContent: $viewModel.password,
                     shouldShowError: .constant(false),
                     destination: ConfirmLockPasswordView(viewModel: viewModel))
    }
}

struct LockPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        LockPasswordView()
    }
}
