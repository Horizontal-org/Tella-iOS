//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct WelcomeView: View {
    var appViewState: AppViewState
    
    var body: some View {
        NavigationContainerView {
            TransitionView(transitionViewData: WelcomeViewData()) {
                let lockViewModel = LockViewModel(lockFlow: .new, appViewState: appViewState)
                let mainOnboardingViewModel = MainOnboardingViewModel(lockViewModel: lockViewModel)
                navigateTo(destination: MainOnboardingView(viewModel: mainOnboardingViewModel))
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
//        WelcomeView(mainAppModel: MainAppModel.stub())
    }
}
