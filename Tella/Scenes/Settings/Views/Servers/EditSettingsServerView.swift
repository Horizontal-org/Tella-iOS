//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct EditSettingsServerView: View {
    
    var isPresented : Binding<Bool>
    
    @StateObject private var serverViewModel : TellaWebServerViewModel
    
    init(appModel:MainAppModel, isPresented : Binding<Bool>, server: TellaServer? = nil) {
        _serverViewModel = StateObject(wrappedValue: TellaWebServerViewModel(mainAppModel: appModel, currentServer: server))
        self.isPresented = isPresented
    }
    
    var body: some View {
        
        ContainerView {
            VStack {
                
                editServerHeaderView
                
                ScrollView {
                    SettingsCardView(cardViewArray:[serverNameView.eraseToAnyView(),
                                                    serverURLView.eraseToAnyView(),
                                                    serverUsernameView.eraseToAnyView()
                                                   ])
                    
                    AdvancedServerSettingsCardView(serverViewModel: serverViewModel)

                }
                
                Spacer()
                
                bottomView
            }
        }
    }
    
    var serverNameView: some View {
        EditServerDisplayItem(title: "Server name", description: serverViewModel.name)
    }
    
    var serverURLView: some View {
        EditServerDisplayItem(title: "Server URL", description: serverViewModel.projectURL)
    }
    
    var serverUsernameView: some View {
        EditServerDisplayItem(title: "Username", description: serverViewModel.username)
    }
    
    var editServerHeaderView : some View {
        
        HStack {
            Button {
                isPresented.wrappedValue = false
            } label: {
                Image("close")
            }.padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
            
            Text("Edit connection")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 20))
                .foregroundColor(Color.white)
            
            Spacer()
            
        }.padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 0))
        
    }
    
    var bottomView : some View {
        
        SettingsBottomView(cancelAction: {
            isPresented.wrappedValue  = false
        }, saveAction: {
            isPresented.wrappedValue  = false
            serverViewModel.updateServer()
        })
    }
}

struct EditSettingsServerView_Previews: PreviewProvider {
    static var previews: some View {
        EditSettingsServerView(appModel: MainAppModel.stub(), isPresented: .constant(true))
    }
}
