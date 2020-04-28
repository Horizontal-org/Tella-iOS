//
//  ContentView.swift
//  Tella
//
//  Created by Anessa Petteruti on 1/30/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @State var currentView: MainViewEnum
    @State var image: Image? = nil

    @State private var showShutdownWarningAlert = false
    
    private func backFunc() {
        self.currentView = .MAIN
    }

    var back: Button<AnyView> {
        return backButton { self.backFunc() }
    }
    
//  setting up the homepage/main view of the app
//  this is the core view that the user will start on and navigate to and from
    func getMainView() -> AnyView {
        return AnyView(Group {
            // title row
            HStack {
                bigText("TELLA")
                Spacer()
                shutdown(isPresented: $showShutdownWarningAlert)
            }
            Spacer()
            // center buttons
            VStack {
                bigLabeledImageButton(.CAMERA, "CAMERA") {
                    self.currentView = .CAMERA
                }
                bigLabeledImageButton(.RECORD, "RECORD") {
                    self.currentView = .RECORD
                }
            }
            Spacer()
            // bottom buttons
            HStack {
                smallLabeledImageButton(.COLLECT, "Collect") {
                    self.currentView = .COLLECT
                }
                smallLabeledImageButton(.GALLERY, "Gallery") {
                    self.currentView = .GALLERY
                }
            }
            HStack {
                Spacer()
                // settings button
                Button(action: {
                    self.currentView = .SETTINGS
                }) {
                    smallImg(.SETTINGS)
                }
                Spacer().frame(maxWidth: 10)
            }
        })
    }

//  updates the current view presented based on the currentView variable
//  the currentView variable is updated when the user clicks ond of the buttons
    func getViewContents(_ currentView: MainViewEnum) -> AnyView {
        switch currentView {
        case .MAIN:
            return getMainView()
        case .CAMERA:
            return AnyView(CameraView(back: backFunc))
        case .COLLECT:
            return AnyView(CollectView(back: back))
        case .RECORD:
            return AnyView(RecordView(back: back))
        case .SETTINGS:
            return AnyView(SettingsView(back: back))
        case .GALLERY:
            guard let privKey = CryptoManager.recoverKey(.PRIVATE) else {
                return AnyView(
                    VStack {
                        smallText("Correct password not input.")
                        back
                    }
                )
            }
            return AnyView(GalleryView(back: back, privKey: privKey))
        case .AUTH:
            return AnyView(PasswordView(back: backFunc))
        }
    }

    var body: some View {
        // makes black background and overlays content
        if currentView == .CAMERA {
            return AnyView(CameraView(back: backFunc))
        } else {
            return AnyView(Color.black
            .edgesIgnoringSafeArea(.all) // ignore just for the color
            .overlay(
                getViewContents(currentView)
                    .padding(mainPadding) // padding for content
            ))
        }
    }
}
