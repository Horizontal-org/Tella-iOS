//
//  ServerSelectionView.swift
//  Tella
//
//  Created by Robert Shrestha on 4/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ServerSelectionView: View {

    @EnvironmentObject var serversViewModel : ServersViewModel
    @StateObject var serverViewModel : ServerViewModel
    @EnvironmentObject var mainAppModel : MainAppModel
    @State var istellaWebSelected = false
    @State var isUwaziSelected = false
    @State var showTellaWeb = false
    @State var showUwazi = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(appModel:MainAppModel, server: Server? = nil) {
        _serverViewModel = StateObject(wrappedValue: ServerViewModel(mainAppModel: appModel, currentServer: server))
    }
    var body: some View {
        ContainerView {

            VStack(spacing: 20) {
                Spacer()
                HeaderView()
                buttonViews()
                Spacer()
                bottomView()
            }
            .toolbar {
                LeadingTitleToolbar(title: LocalizableSettings.settServersAppBar.localized)
            }
        }
    }
    fileprivate func buttonViews() -> Group<TupleView<(some View, some View)>> {
        return Group {
            TellaButtonView<AnyView>(title: LocalizableSettings.settServerTellaWeb.localized,
                                     nextButtonAction: .action,
                                     isOverlay: self.istellaWebSelected,
                                     isValid: .constant(true),action: {
                istellaWebSelected = true
                isUwaziSelected = false
            })
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            TellaButtonView<AnyView>(title: LocalizableSettings.settServerUwazi.localized,
                                     nextButtonAction: .action,
                                     isOverlay: self.isUwaziSelected,
                                     isValid: .constant(true), action: {
                istellaWebSelected = false
                isUwaziSelected = true
            }).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        }
    }

    fileprivate func bottomView() -> BottomLockView<AnyView> {
        return BottomLockView<AnyView>(isValid: .constant(true),
                                       nextButtonAction: .action,
                                       shouldHideNext: false,
                                       shouldHideBack: true,
                                       nextAction: {
            if istellaWebSelected {
                navigateTo(destination: AddServerURLView(appModel: mainAppModel))
            } else if isUwaziSelected {
                navigateTo(destination: UwaziAddServerURLView(appModel: mainAppModel)
                    .environmentObject(serverViewModel)
                    .environmentObject(serversViewModel))
            } else {

            }
        })
    }

    struct HeaderView: View {
        var body: some View {
            VStack(spacing: 20) {
                Image("settings.server")
                Text(LocalizableSettings.settServerSelectionTitle.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(LocalizableSettings.settServerSelectionMessage.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
    }
    private var tellaWebLink: some View {
        AddServerURLView(appModel: mainAppModel)
            .environmentObject(serversViewModel)
            //.addNavigationLink(isActive: $showTellaWeb)
    }
}

struct ServerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ServerSelectionView(appModel: MainAppModel.stub())
            .environmentObject(MainAppModel.stub())
            .environmentObject(ServersViewModel(mainAppModel: MainAppModel.stub()))
    }
}
