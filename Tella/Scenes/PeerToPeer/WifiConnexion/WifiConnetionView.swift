//
//  WifiConnetionView.swift
//  Tella
//
//  Created by RIMA on 31.01.25.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct WifiConnetionView: View {
    
    @StateObject var viewModel: WifiConnetionViewModel
    @StateObject var mainAppModel: MainAppModel
    
    @State private var isExpanded = true
    @State var isCheckboxOn = false
    @EnvironmentObject private var sheetManager: SheetManager
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
        .onReceive(viewModel.$showPermissionAlert) { showPermissionAlert in
            if showPermissionAlert {
                getSettingsAlertView()
            }
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .center, spacing: 24) {
            Spacer()
            topView
            DividerView()
            wifiInfoView
            Spacer()
            bottomView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.leading, .trailing], 20)
    }
    
    private var wifiInfoView: some View {
        VStack(alignment: .center, spacing: 12) {
            currentWifiView
            sameWifiNetworkView
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.wifi.localized ,
                             navigationBarType: .inline,
                             rightButtonType: .none)
    }
    
    var lineView: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.white.opacity(0.2))
    }
    
    var topView: some View {
        VStack(alignment: .center, spacing: 12) {
            
            ServerConnectionHeaderView(
                title: LocalizablePeerToPeer.getConnected.localized,
                subtitle: LocalizablePeerToPeer.wifiConnectionDescription.localized,
                imageIconName: "wifi.icon",
                subtitleTextAlignment: .leading)
            tipsView
        }
    }
    
    
    
    var tipsView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                CustomText(LocalizablePeerToPeer.wifiConnectionTipsToConnect.localized,
                           style: .body1Style)
                
                if isExpanded {
                    Spacer()
                        .frame(height: 2)
                    CustomText(LocalizablePeerToPeer.wifiConnectionTipsToConnectDescription.localized,
                               style: .body2Style)
                }
            }
            Spacer()
            ResizableImage("arrow.up")
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(isExpanded ? 0 : 180 )) // rotate icon
                .animation(.easeInOut, value: isExpanded)
            
        }
        .cardModifier()
        .animation(.easeInOut, value: isExpanded) // Apply animation to the whole view
        .onTapGesture {
            withAnimation(.easeInOut) {
                isExpanded.toggle()
            }
        }
    }
    
    private var currentWifiView: some View {
        HStack {
            CustomText(LocalizablePeerToPeer.currentWifi.localized, style: .body1Style)
            
            Spacer()
            
            if let ssid = viewModel.ssid {
                CustomText("\(ssid)",
                           style: .body1Style)
            } else {
                CustomText(LocalizablePeerToPeer.noConnection.localized,
                           style: .body1Style,
                           color: .gray)
            }
            
        }.cardModifier()
    }
    
    var sameWifiNetworkView: some View {
        HStack {
            CustomText(LocalizablePeerToPeer.wifiSameNetworkDescription.localized,
                       style: .body1Style)
            Spacer()
            ResizableImage(isCheckboxOn ? "checkbox.on" : "checkbox.off")
                .frame(width: 24, height: 24)
                .onTapGesture {
                    isCheckboxOn.toggle()
                }
                .disabled(viewModel.ssid == nil)
            
        }.cardModifier()
            .opacity(viewModel.ssid == nil ? 0.5 : 1.0)
    }
    
    var bottomView: some View {
        NavigationBottomView<AnyView>(shouldActivateNext: $isCheckboxOn,
                                      nextButtonAction: .action,
                                      shouldHideBack: true,
                                      nextAction: {
            switch viewModel.participant {
            case .sender:
                let senderConnectToDeviceViewModel = SenderConnectToDeviceViewModel(peerToPeerRepository:PeerToPeerRepository(),
                                                                                    mainAppModel: mainAppModel)
                navigateTo(destination: SenderConnectToDeviceView(viewModel:senderConnectToDeviceViewModel))
            case .recipient:
                let recipientConnectToDeviceViewModel = RecipientConnectToDeviceViewModel(certificateGenerator: CertificateGenerator(),
                                                                                          mainAppModel: mainAppModel)
                navigateTo(destination: RecipientConnectToDeviceView(viewModel: recipientConnectToDeviceViewModel))
            }
        })
    }
    
    private func getSettingsAlertView() {
        sheetManager.showBottomSheet(modalHeight: 190) {
            ConfirmBottomSheet(titleText: LocalizablePeerToPeer.locationAccess.localized,
                               msgText: LocalizablePeerToPeer.detectWifiSettingsDesc.localized,
                               cancelText: LocalizablePeerToPeer.cancel.localized.uppercased(),
                               actionText: LocalizablePeerToPeer.settings.localized.uppercased(), didConfirmAction: {
                UIApplication.shared.openSettings()
            }, didCancelAction: {
                self.viewModel.showPermissionAlert = false
                sheetManager.hide()
            })
        }
    }
}

#Preview {
    WifiConnetionView(viewModel: WifiConnetionViewModel(participant: .recipient,
                                                        mainAppModel: MainAppModel.stub()),
                      mainAppModel: MainAppModel.stub())
}


