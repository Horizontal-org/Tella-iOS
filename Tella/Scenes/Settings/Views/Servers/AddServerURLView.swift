//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddServerURLView: View {
    
    @EnvironmentObject var serversViewModel : ServersViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showNextView : Bool = false
    
    var action : (() -> Void)?
    var nextButtonAction: NextButtonAction = .action
    
    var body: some View {
        
        ContainerView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                Image("settings.server")
                
                Spacer()
                    .frame(height: 24)
                
                Text("Enter the project URL")
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                
                Spacer()
                    .frame(height: 40)
                
                TextfieldView(fieldContent: $serversViewModel.serverURL,
                              isValid: $serversViewModel.validURL,
                              shouldShowError: $serversViewModel.shouldShowError,
                              errorMessage: serversViewModel.errorMessage,
                              fieldType: .url)
                Spacer()
                
                BottomLockView<AnyView>(isValid: $serversViewModel.validURL,
                                        nextButtonAction: .action,
                                        nextAction: {
                    serversViewModel.checkURL()
                    showNextView = !serversViewModel.shouldShowError
                },
                                        backAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
                
                nextViewLink
                
            } .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .navigationBarHidden(true)
        
    }
    
    private var nextViewLink: some View {
        AddServerAccessChoiceView().environmentObject(serversViewModel)
            .addNavigationLink(isActive: $showNextView)
    }
    
}

struct AddServerURLView_Previews: PreviewProvider {
    static var previews: some View {
        AddServerURLView()
    }
}
