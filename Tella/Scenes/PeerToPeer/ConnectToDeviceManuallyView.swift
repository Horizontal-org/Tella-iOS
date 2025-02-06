//
//  ConnectToDeviceManuallyView.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ConnectToDeviceManuallyView: View {
    
    @ObservedObject var viewModel: ConnectToDeviceManuallyViewModel
    
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
                ScrollView {
                    topView.padding(.bottom, 16)
                    ipAddressTextFieldView
                    pinTextFieldView
                    portTextFieldView
                    publicKeyTextFieldView
                }
            }
            Spacer()
            bottomView
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
            RegularText(LocalizablePeerToPeer.enterDeviceInformation.localized, size: 18).multilineTextAlignment(.center)
                .frame(height: 50)
        }
    }
    
    var ipAddressTextFieldView: some View {
        TextfieldView(fieldContent: $viewModel.ipAddress,
                      isValid: $viewModel.valid,
                      shouldShowError: .constant(false),
                      fieldType: .text,
                      placeholder : LocalizablePeerToPeer.ipAddress.localized)
        .frame(height: 78)
    }
    var pinTextFieldView: some View {
        TextfieldView(fieldContent: $viewModel.pin,
                      isValid: $viewModel.valid,
                      shouldShowError: .constant(false),
                      fieldType: .text,
                      placeholder : LocalizablePeerToPeer.pin.localized)
        .frame(height: 78)
    }
    var portTextFieldView: some View {
        TextfieldView(fieldContent: $viewModel.port,
                      isValid: $viewModel.valid,
                      shouldShowError: .constant(false),
                      fieldType: .text,
                      placeholder : LocalizablePeerToPeer.port.localized)
        .frame(height: 78)
    }
    var publicKeyTextFieldView: some View {
        TextfieldView(fieldContent: $viewModel.publicKey,
                      isValid: $viewModel.valid,
                      shouldShowError: .constant(false),
                      fieldType: .text,
                      placeholder : LocalizablePeerToPeer.publicKey.localized)
        .frame(height: 78)
    }
    
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: $viewModel.validFields,
                                nextButtonAction: .action,
                                nextAction: {
            /*
             TODO:
             */
            
        },
                                backAction: {
            /*
             TODO:
             */
        })
        
    }
}

