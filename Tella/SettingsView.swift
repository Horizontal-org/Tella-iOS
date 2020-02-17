//
//  SettingsView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//


import SwiftUI

struct SettingsView: View {
    
    let back: Button<AnyView>
    
    var body: some View {
        return Group {
//            mediumText("SETTINGS")
//            back
            HStack {
                Button(action: {
                    print("back button pressed")
                }) {
                    back
                }
                Spacer()
                mediumText("SETTINGS")
                Spacer()
                Button(action: {
                    print("shutdown button pressed")
                }) {
                    mediumImg(.SHUTDOWN)
                }
            }
            VStack {
                Spacer().frame(maxHeight: 30)
                HStack {
                    smallImg(.KEY)
                    Spacer().frame(maxWidth: 15)
                    Button(action: {
                        print("change password button pressed")
                    }) {
                        smallText("Change password")
                    }
                
                    Spacer()
                }
                Spacer().frame(maxHeight: 15)
                HStack {
                    smallImg(.KEYTYPE)
                    Spacer().frame(maxWidth: 15)
                    Button(action: {
                        print("change password type button pressed")
                    }) {
                        smallText("Change password type")
                    }
                
                    Spacer()
                }
            }
            Spacer()
        }
    }
}
