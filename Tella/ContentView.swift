//
//  ContentView.swift
//  Tella
//
//  Created by Anessa Petteruti on 1/30/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        return VStack {
            // title row
            HStack {
                bigText("TELLA")
                Spacer()
                Button(action: {
                    print("shutdown button pressed")
                }) {
                    bigImg("shutdown-icon")
                }
            }
            Spacer()
            // center buttons
            VStack {
                bigLabeledImageButton("camera-icon", "CAMERA") {
                    print("camera button pressed")
                }
                bigLabeledImageButton("record-icon", "RECORD") {
                    print("record button pressed")
                }
            }
            Spacer()
            // bottom buttons
            HStack {
                smallLabeledImageButton("collect-icon", "Collect") {
                    print("collect button pressed")
                }
                Spacer()
                smallLabeledImageButton("gallery-icon", "Gallery") {
                    print("gallery button pressed")
                }
            }
            // settings button
            Button(action: {
                print("settings button pressed")
            }) {
                smallImg("settings-icon")
            }
        }
            .padding(20)
            .background(Color.black)
    }
}

struct ontentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
