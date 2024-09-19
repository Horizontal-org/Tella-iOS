//
//  UwaziLoginView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/24/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziLoginView: View {
    @EnvironmentObject var uwaziServerViewModel : UwaziServerViewModel
    @EnvironmentObject var serversViewModel : ServersViewModel
    
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
        let languageView = UwaziLanguageSelectionView(isPresented: .constant(true))
            .environmentObject(serversViewModel)
            .environmentObject(uwaziServerViewModel)
        navigateTo(destination: languageView)
    }
    
    fileprivate func show2FAView() {
        let twoStepVerification =  UwaziTwoStepVerification()
            .environmentObject(serversViewModel)
            .environmentObject(uwaziServerViewModel)
        if !uwaziServerViewModel.shouldShowLoginError {
            navigateTo(destination: twoStepVerification)
        }
    }
}

struct UwaziLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UwaziLoginView()
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
            .environmentObject(TellaWebServerViewModel(mainAppModel: MainAppModel.stub(), currentServer: nil))
    }
}
