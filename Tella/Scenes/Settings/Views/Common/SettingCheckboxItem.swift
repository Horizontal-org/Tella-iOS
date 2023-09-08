//
//  SettingCheckboxItem.swift
//  Tella
//
//  Created by Gustavo on 24/02/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

import SwiftUI

struct SettingCheckboxItem: View {
    @Binding var isChecked: Bool
    @EnvironmentObject var appModel : MainAppModel
    
    var title: String
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
            appModel.saveSettings()
        }) {
            HStack {
                VStack(alignment: .leading){
                    Text(title)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(Color.white).padding(.bottom, -5)
                }
                Spacer()
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
            }
        }
        .padding()
    }
}
