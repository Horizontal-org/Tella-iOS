//
//  WifiConnexionView.swift
//  Tella
//
//  Created by RIMA on 31.01.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
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
        VStack {
            getConnectedView
            tipsView
            DividerView()
            currentWifiView
            sameWifiNetworkView
            Spacer()
            bottomView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding([.leading, .trailing], 20)
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.wifi.localized ,
                             navigationBarType: .inline,
                             backButtonAction: {self.popToRoot()},
                             rightButtonType: .none)
    }
    
    var lineView: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.white.opacity(0.2))
    }
    
    var getConnectedView: some View {
        VStack(alignment: .center, spacing: 12) {
            Spacer().frame(height: 20)
            VStack {
                ResizableImage("wifi.icon").frame(width: 43, height: 30)
                RegularText(LocalizablePeerToPeer.getConnected.localized, size: 18)
            }
            
            RegularText(LocalizablePeerToPeer.wifiConnectionDescription.localized)
                .frame(maxWidth: .infinity, alignment: .leading)
            
        }.frame(maxWidth: .infinity)
    }
    
    var tipsView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                RegularText(LocalizablePeerToPeer.wifiConnectionTipsToConnect.localized)
                Spacer()
                if isExpanded {
                    Text(LocalizablePeerToPeer.wifiConnectionTipsToConnectDescription.localized)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(Color.white)
                    
                }
            }
            Spacer()
            ResizableImage( isExpanded ? "arrow.up" : "arrow.down" ).frame(width: 24, height: 24)
        }
        .cardModifier()
        .frame(height: isExpanded ? 180 : 56 )
        .onTapGesture {
            isExpanded.toggle()
        }
        .padding(.bottom, 24)
    }
    
    var currentWifiView: some View {
        HStack {
            RegularText(LocalizablePeerToPeer.currentWifi.localized)
            Spacer()
            
            if let ssid = viewModel.ssid {
                RegularText("\(ssid)")
            } else {
                Text(LocalizablePeerToPeer.notConnected.localized)
                    .foregroundColor(.gray)
            }
            
        }.cardModifier()
            .frame(height: 53)
            .padding(.top, 24)
    }
    
    var sameWifiNetworkView: some View {
        HStack {
            RegularText(LocalizablePeerToPeer.wifiSameNetworkDescription.localized)
            Spacer()
            ResizableImage( isCheckboxOn ? "checkbox.on" : "checkbox.off" )
                .frame(width: 24, height: 24)
                .onTapGesture {
                    isCheckboxOn.toggle()
                }
                .disabled(viewModel.ssid == nil)
            
        }.cardModifier()
            .frame(height: 74)
            .padding(.top, 12)
            .opacity(viewModel.ssid == nil ? 0.5 : 1.0)
    }
    
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: $isCheckboxOn,
                                nextButtonAction: .action,
                                nextAction: {
            switch viewModel.participent {
            case .sender:
                navigateTo(destination: SenderConnectToDeviceView(viewModel: SenderConnectToDeviceViewModel()))
            case .recipient:
                navigateTo(destination: RecipientConnectToDeviceView(viewModel: RecipientConnectToDeviceViewModel(certificateManager: CertificateManager(), mainAppModel: mainAppModel)))
            }
        },  backAction: {
            self.dismiss()
        })
    }
    
    private func getSettingsAlertView() {
        sheetManager.showBottomSheet(modalHeight: 170) {
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
    WifiConnetionView(viewModel: WifiConnetionViewModel(participent: .recipient,
                                                        mainAppModel: MainAppModel.stub()),
                      mainAppModel: MainAppModel.stub())
}


