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
                navigateTo(destination: LockChoiceView(isPresented: .constant(false)))
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
