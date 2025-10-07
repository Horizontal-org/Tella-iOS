//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject private var appViewState: AppViewState
    
    var body: some View {
        NavigationContainerView {
            TransitionView(transitionViewData: WelcomeViewData()) {
                let lockViewModel = LockViewModel(unlockType: .new, appViewState: appViewState)
                navigateTo(destination: MainOnboardingView(viewModel: MainOnboardingViewModel(),lockViewModel: lockViewModel))
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
