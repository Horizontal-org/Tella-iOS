//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    
    @State var shouldShowLockChoice : Bool = false
    var action: (() -> Void)?
    
    var body: some View {
        NavigationContainerView {
            TransitionView(transitionViewData: WelcomeViewData()) {
                shouldShowLockChoice = true
            }
            onboardingLink
        }
    }
    
    private var onboardingLink: some View {
        NavigationLink(destination: LockChoiceView(isPresented: .constant(false)) ,
                       isActive: $shouldShowLockChoice) {
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
