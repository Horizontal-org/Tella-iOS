//
//  MainServerOnboardingView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct MainServerOnboardingView: View {
    
    var appViewState: AppViewState
    var serversViewModel: ServersViewModel
    
    var body: some View {
        
        VStack(spacing: 50) {
            Spacer()
            
            OnboardingPageView(content: MainServerOnboardingContent())
            VStack(spacing: 12) {
                
                TellaButtonView<AnyView> (title: LocalizableLock.onboardingServerMainConnectServer.localized.uppercased(),
                                          nextButtonAction: .action,
                                          buttonType: .clear,
                                          isValid: .constant(true)) {
                    let destination = ServerSelectionView(serversViewModel: serversViewModel)
                    self.navigateTo(destination: destination)
                }
                
                TellaButtonView<AnyView> (title: LocalizableLock.onboardingServerMainContinue.localized.uppercased(),
                                          nextButtonAction: .action,
                                          buttonType: .clear,
                                          isValid: .constant(true)) {
                    self.appViewState.resetToMain()
                    
                }
            }
            Spacer()
        }.padding(.horizontal,25)
        
    }
}

