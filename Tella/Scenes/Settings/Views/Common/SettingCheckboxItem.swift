//
//  SettingCheckboxItem.swift
//  Tella
//
//  Created by Gustavo on 24/02/2023.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

import SwiftUI

struct SettingCheckboxItem: View {
    @Binding var isChecked: Bool
    var mainAppModel : MainAppModel
    
    var title: String
    var helpText: String?
    
    var body: some View {
        
        HStack() {
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white)
            
            if let helpText {
                HelpIcon(text: helpText)
            }
            
            Spacer()
            
            Button {
                isChecked.toggle()
                mainAppModel.saveSettings()
            } label: {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .padding(.all, 16)
            }
        }.padding(.leading, 16)
    }
}
