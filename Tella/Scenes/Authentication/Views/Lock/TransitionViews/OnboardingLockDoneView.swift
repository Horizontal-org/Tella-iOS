//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct OnboardingLockDoneView: View {
    
    var appViewState: AppViewState
    
    var body: some View {
        
        VStack(spacing: 50) {
            Spacer()
            
            OnboardingPageView(content: LockDoneContent())
            VStack(spacing: 12) {
                
                TellaButtonView<AnyView> (title: LocalizableLock.goToTella.localized.uppercased(),
                                          nextButtonAction: .action,
                                          buttonType: .yellow,
                                          isValid: .constant(true)) {
                    self.appViewState.resetToMain()
                }
                
                TellaButtonView<AnyView> (title: LocalizableLock.advancedSettings.localized.uppercased(),
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
        }.padding(.horizontal,25)
    }
}

//struct OnboardingEndView_Previews: PreviewProvider {
//    static var previews: some View {
//        OnboardingLockDoneView(appViewState: AppViewState.)
//    }
//}
