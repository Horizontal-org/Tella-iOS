//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct OnboardingLockDoneView: View {
    
    var appViewState: AppViewState
    
    var body: some View {
        
        VStack(spacing: .extraLarge) {
            Spacer()
            
            ImageTitleMessageView(content: LockDoneContent())
            VStack(spacing: .small) {
                
                TellaButtonView(title: LocalizableLock.goToTella.localized.uppercased(),
                                nextButtonAction: .action,
                                buttonType: .yellow,
                                isValid: .constant(true)) {
                    self.appViewState.resetToMain()
                }
                
                TellaButtonView(title: LocalizableLock.advancedSettings.localized.uppercased(),
                                nextButtonAction: .action,
                                buttonType: .clear,
                                isValid: .constant(true)) {
                    let serversViewModel = ServersViewModel(mainAppModel: appViewState.homeViewModel,
                                                            serversSourceView: .onboarding)
                    let serverOnboardingViewModel = ServerOnboardingViewModel(mainAppModel: appViewState.homeViewModel)
                    
                    navigateTo(destination: ServerOnboardingView(appViewState: appViewState,
                                                                 viewModel: serverOnboardingViewModel,
                                                                 serversViewModel: serversViewModel))
                }
            }
            Spacer()
        }.padding(.horizontal,.medium)
    }
}

#Preview {
    OnboardingLockDoneView(appViewState: AppViewState.stub())
        .background(Styles.Colors.backgroundMain)
}
