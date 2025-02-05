//
//  WifiConnexionView.swift
//  Tella
//
//  Created by RIMA on 31.01.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct WifiConnetionView: View {
    
    @StateObject private var viewModel = WifiConnetionViewModel()
    @State private var isExpanded = false
    @State var isCheckboxOn = false

    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            VStack {
                getConnectedView
                tipsView
                lineView
                currentWifiView
                sameWifiNetworkView
                Spacer()
                bottomView
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding([.leading, .trailing], 20)
            
        }
        .alert(isPresented: $viewModel.showPermissionAlert) {
            getSettingsAlertView()
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: "Wi-Fi",
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
                Text("Not connected") //Add text to localizable when it is confirmed
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
            ResizableImage( isCheckboxOn ? "checkbox.on" : "checkbox.off" ).frame(width: 24, height: 24)
                .onTapGesture {
                    isCheckboxOn.toggle()
                }
        }.cardModifier()
            .frame(height: 74)
            .padding(.top, 12)
    }
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: $isCheckboxOn,
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
    
    
    private func getSettingsAlertView() -> Alert {
        // To Fix Text
        Alert(title: Text(""),
              message: Text("Please enable location access in Settings to detect the Wi-Fi network."),
              primaryButton: .default(Text(LocalizableRecorder.deniedAudioPermissionActionCancel.localized), action: {
            self.viewModel.showPermissionAlert = false
            
        }), secondaryButton: .default(Text(LocalizableRecorder.deniedAudioPermissionActionSettings.localized), action: {
            UIApplication.shared.openSettings()
        }))
        
    }
}

#Preview {
    WifiConnetionView()
}


