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
        
        .onReceive(viewModel.$viewState) { state in
            handleViewState(state: state)
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
            CustomText(LocalizablePeerToPeer.showDeviceInformation.localized, style: .heading1Style)
                .frame(height: 50)
            CustomText(LocalizablePeerToPeer.sendInputDesc.localized, style: .body1Style)
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

    private func handleViewState(state: RecipientConnectToDeviceViewState) {
        switch state {
        case .showVerificationHash:
 
            guard let connectionInfo = viewModel.connectionInfo else { return  }
            let viewModel = ManuallyVerificationViewModel(participant:.recipient,
                                                          connectionInfo: connectionInfo,
                                                          mainAppModel: viewModel.mainAppModel)
            self.navigateTo(destination: ManuallyVerificationView(viewModel: viewModel ))

            
            
        case .showToast(let message):
            Toast.displayToast(message: message)
        default:
            break
        }
    }

}

