//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    
    @State var shouldShowLockPinView : Bool = false
    var action: (() -> Void)?
    
    var body: some View {
        NavigationContainerView {
            TransitionView(transitionViewData: WelcomeViewData()) {
                shouldShowLockPinView = true
            }
            onboardingLink
        }
    }
    
    private var onboardingLink: some View {
        NavigationLink(destination: LockPinView() ,
                       isActive: $shouldShowLockPinView) {
            EmptyView()
        }.frame(width: 0, height: 0)
            .hidden()
    }
    
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
