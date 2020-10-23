//
//  MainView.swift
//  Tella
//
//  Created by Rance Tsai on 9/7/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appViewState: AppViewState
    @State private var showShutdownWarningAlert = false

    var body: some View {
        Group {
            // title row
            HStack {
                bigText("TELLA", true)
                Spacer()
                ShutdowButton(isPresented: $showShutdownWarningAlert)
            }
            Spacer()
            // center buttons
            VStack {
                bigLabeledImageButton(.CAMERA, "CAMERA") {
                    self.appViewState.navigate(to: .CAMERA)
                }
                bigLabeledImageButton(.RECORD, "RECORD") {
                    self.appViewState.navigate(to: .RECORD)
                }
            }
            Spacer()
            // bottom buttons
            HStack {
                smallLabeledImageButton(.COLLECT, "Collect") {
                    self.appViewState.navigate(to: .COLLECT)
                }
                smallLabeledImageButton(.GALLERY, "Gallery") {
                    self.appViewState.navigate(to: .GALLERY)
                }
            }
            HStack {
                Spacer()
                // settings button
                Button(action: {
                    self.appViewState.navigate(to: .SETTINGS)
                }) {
                    smallImg(.SETTINGS)
                }
                Spacer().frame(maxWidth: 10)
            }
        }
    }
}
