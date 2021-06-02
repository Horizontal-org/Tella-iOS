//
//  ContentView.swift
//  Tella
//
//  Created by Anessa Petteruti on 1/30/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appViewState: AppViewState

//  updates the current view presented based on the currentView variable
//  the currentView variable is updated when the user clicks ond of the buttons
    func getViewContents(_ currentView: MainViewEnum) -> some View {
        switch currentView {
        case .MAIN:
            return MainView().eraseToAnyView()
        case .CAMERA:
            return CameraView().eraseToAnyView()
        case .COLLECT:
            return CollectView().eraseToAnyView()
        case .RECORD:
            return RecordView().eraseToAnyView()
        case .SETTINGS:
            return SettingsView_old().eraseToAnyView()
        case .GALLERY:
            guard let privKey = CryptoManagerV1.recoverKey(.PRIVATE) else {
                return VStack {
                    smallText("Correct password not input.")
                    BackButton {
                        self.appViewState.navigateBack()
                    }
                }.eraseToAnyView()
            }
            return GalleryView(privKey: privKey).eraseToAnyView()
        case .AUTH:
            return PasswordView().eraseToAnyView()
        case .VIDEO:
            return PasswordView().eraseToAnyView()
//            return VideoRecordingView().eraseToAnyView()
        }
    }

    var body: some View {
        // makes black background and overlays content
        if appViewState.currentView == .CAMERA {
            return CameraView().eraseToAnyView()
        }
        
        if appViewState.currentView == .VIDEO {
            return PasswordView().eraseToAnyView()
//            return VideoRecordingView().eraseToAnyView()
        }
        return Color.black
            .edgesIgnoringSafeArea(.all) // ignore just for the color
            .overlay(
                getViewContents(appViewState.currentView)
                    .padding(mainPadding) // padding for content
            )
            .eraseToAnyView()
    }
}
