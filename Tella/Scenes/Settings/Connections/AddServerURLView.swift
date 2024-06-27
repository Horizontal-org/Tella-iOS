//
//  AddServerURLView.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct AddServerURLView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var serversViewModel: ServersViewModel
    @StateObject var viewModel: ServerViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                Image("settings.server")
                Spacer()
                    .frame(height: 24)
                Text(LocalizableSettings.serverURL.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 18))
                    .foregroundColor(.white)
                Spacer()
                    .frame(height: 40)
                TextfieldView(fieldContent: $viewModel.serverURL,
                              isValid: $viewModel.validURL,
                              shouldShowError: $viewModel.shouldShowURLError,
                              errorMessage: viewModel.urlErrorMessage,
                              fieldType: .url)
                Spacer()
                
                BottomLockView<AnyView>(isValid: $viewModel.validURL,
                                        nextButtonAction: .action,
                                        nextAction: {
                    self.viewModel.checkURL()
                },
                                        backAction: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            } .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            if viewModel.isLoading {
                CircularActivityIndicatory()
            }
        }
        .containerStyle()
        .navigationBarHidden(true)
    }
}
