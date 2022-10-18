//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddServerAccessChoiceView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var serversViewModel : ServersViewModel
    
    var body: some View {
        ContainerView {
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    TopServerView(title: "Do you have a username and password?")
                        .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
                    
                    Spacer()
                        .frame(height: 40)
                    
                    TellaButtonView(title: "YES",
                                    nextButtonAction: .destination,
                                    destination: ServerLoginView().environmentObject(serversViewModel),
                                    isValid: .constant(true) )
                    
                    Spacer()
                        .frame(height: 12)
                    
                    TellaButtonView (title: "NO",
                                    nextButtonAction: .destination,
                                    destination: ServerLoginView().environmentObject(serversViewModel),
                                     isValid: .constant(true))
                    
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
        .navigationBarHidden(true)
    }
}

struct AddServerAccessChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        AddServerAccessChoiceView()
    }
}
