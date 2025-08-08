//
//  ConnectToDeviceManuallyView.swift
//  Tella
//
//  Created by RIMA on 05.02.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct SenderConnectToDeviceManuallyView: View {
    
    @ObservedObject var viewModel: ConnectToDeviceManuallyVM
    @State var isBottomSheetShown : Bool = false
    
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
            Spacer()
            
            VStack {
                topView
                Spacer()
                    .frame(height: 24)
                textFieldsView
            }
            
            Spacer()
            bottomView
        }
        .padding([.leading, .trailing], 16)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableNearbySharing.connectManually.localized,
                             navigationBarType: .inline,
                             backButtonType: .close,
                             rightButtonType: .none)
    }
    
    var topView: some View {
        ServerConnectionHeaderView(
            title: LocalizableNearbySharing.enterDeviceInformation.localized,
            imageIconName: "device",
            subtitleTextAlignment: .leading)
    }
    
    var textFieldsView: some View {
        VStack(spacing:8) {
            ScrollView {
                ipAddressTextFieldView
                pinTextFieldView
                portTextFieldView
            }
        }
    }
    
    var ipAddressTextFieldView: some View {
        TextfieldView(fieldContent: $viewModel.ipAddress,
                      isValid: $viewModel.isValidIpAddress,
                      shouldShowError: $viewModel.shouldShowIpAddressError,
                      errorMessage: LocalizableNearbySharing.invalidIpAddress.localized,
                      fieldType: .ipAddress,
                      placeholder : LocalizableNearbySharing.ipAddress.localized)
        .frame(height: 78)
    }
    
    var pinTextFieldView: some View {
        TextfieldView(fieldContent: $viewModel.pin,
                      isValid: $viewModel.isValidPin,
                      shouldShowError: $viewModel.shouldShowPinError ,
                      errorMessage:LocalizableNearbySharing.invalidPin.localized,
                      fieldType: .pin,
                      placeholder : LocalizableNearbySharing.pin.localized)
        .frame(height: 78)
    }
    
    var portTextFieldView: some View {
        TextfieldView(fieldContent: $viewModel.port,
                      isValid: $viewModel.isValidPort,
                      shouldShowError:  .constant(false),
                      fieldType: .port,
                      placeholder : LocalizableNearbySharing.port.localized)
        .frame(height: 78)
    }
    
    var bottomView: some View {
        NavigationBottomView<AnyView>(shouldActivateNext: $viewModel.validFields,
                                      nextButtonAction: .action,
                                      shouldHideBack: true,
                                      nextAction: {
            viewModel.getHash()
        })
    }
    
    private func handleViewState(state: SenderConnectToDeviceViewAction) {
        switch state {
        case .showBottomSheetError:
            showBottomSheetError()
        case .showVerificationHash:
            guard let connectionInfo = viewModel.connectionInfo else { return  }
            let viewModel = ManuallyVerificationViewModel(participant: .sender,
                                                          nearbySharingRepository:viewModel.nearbySharingRepository,
                                                          connectionInfo: connectionInfo,
                                                          mainAppModel: viewModel.mainAppModel)
            self.navigateTo(destination: ManuallyVerificationView(viewModel: viewModel ))
            
        case .showToast(let message):
            Toast.displayToast(message: message)
        default:
            break
        }
    }
    
    private func showBottomSheetError() {
        isBottomSheetShown = true
        let content = ConnectionFailedView()
        self.showBottomSheetView(content: content, modalHeight: 192, isShown: $isBottomSheetShown)
    }
}

