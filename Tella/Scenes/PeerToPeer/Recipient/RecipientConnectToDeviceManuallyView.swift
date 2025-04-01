//
//  RecipientConnectToDeviceManuallyView.swift
//  Tella
//
//  Created by RIMA on 10.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RecipientConnectToDeviceManuallyView: View {
    
    @StateObject var viewModel: RecipientConnectManuallyViewModel
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    var contentView: some View {
        VStack {
            VStack {
                topView.padding(.bottom, 16)
                VStack(spacing: 8) {
                    CardItemView(title: LocalizablePeerToPeer.ipAddress.localized, subtitle: viewModel.ipAddress)
                    CardItemView(title: LocalizablePeerToPeer.pin.localized, subtitle: viewModel.pin)
                    CardItemView(title: LocalizablePeerToPeer.port.localized, subtitle: viewModel.port)
                }
            }
            Spacer()
            backButton
        }
        .padding([.leading, .trailing], 16)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.connectToDevice.localized,
                             navigationBarType: .inline,
                             backButtonType: .close,
                             backButtonAction: {self.popToRoot()}, //TO Check
                             rightButtonType: .none)
    }
    
    var topView: some View {
        VStack(alignment: .center) {
            ResizableImage("device").frame(width: 120, height: 120)
            RegularText(LocalizablePeerToPeer.showDeviceInformation.localized, size: 18).multilineTextAlignment(.center)
                .frame(height: 50)
            RegularText(LocalizablePeerToPeer.sendInputDesc.localized)
        }
    }
    
    var backButton: some View {
        HStack {
            Button {
                // TO DO- back to the previous view
            } label: {
                Text(LocalizableLock.actionBack.localized)
            }
            .font(.custom(Styles.Fonts.lightFontName, size: 16))
            Spacer()
        }.padding(16)
    }
}

