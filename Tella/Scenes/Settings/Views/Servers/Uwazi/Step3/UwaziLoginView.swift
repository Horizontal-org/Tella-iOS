//
//  UwaziLoginView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/24/23.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziLoginView: View {
    @StateObject var uwaziServerViewModel : UwaziServerViewModel
    
    var body: some View {
        ServerLoginView(viewModel: uwaziServerViewModel)
            .onReceive(uwaziServerViewModel.$showNextLanguageSelectionView, perform: { value in
                if value {
                    showLanguageSelectionView()
                }
            })
            .onReceive(uwaziServerViewModel.$showNext2FAView, perform: { value in
                if value {
                    show2FAView()
                }
            })
            .onAppear {
                self.uwaziServerViewModel.fillUwaziCredentials()
            }
    }
    
    fileprivate func showLanguageSelectionView() {
        let languageView = UwaziLanguageSelectionView(isPresented: .constant(true),
                                                      uwaziServerViewModel: uwaziServerViewModel)
        navigateTo(destination: languageView)
    }
    
    fileprivate func show2FAView() {
        let twoStepVerification =  UwaziTwoStepVerification(uwaziServerViewModel: uwaziServerViewModel)
        if !uwaziServerViewModel.shouldShowLoginError {
            navigateTo(destination: twoStepVerification)
        }
    }
}

struct UwaziLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziLoginView(uwaziServerViewModel: UwaziServerViewModel.stub())
    }
}
