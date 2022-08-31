//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddServerAccessChoiceView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ContainerView {
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    TopServerView(title: "Do you have a username and password?")
                    
                    Spacer()
                        .frame(height: 40)
                    
                    BlueButtonView<AnyView>(title: "YES")
                    
                    Spacer()
                        .frame(height: 12)
                    
                    BlueButtonView<AnyView>(title: "NO")
                    
                    Spacer()
                    
                }.padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
              
                BottomLockView<AnyView>(isValid: .constant(true),
                                        nextButtonAction: .action,
                                        shouldHideNext: true,
                                        backAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

struct AddServerAccessChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        AddServerAccessChoiceView()
    }
}
