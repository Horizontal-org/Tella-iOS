//
//  BottomButtonsView.swift
//  Tella
//
//  Created by Gustavo on 11/07/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct BottomButtonsView : View {
    
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var settingsViewModel : SettingsViewModel
    
    var cancelAction: () -> Void
    var cancelLabel: String
    var saveAction: () -> Void
    var saveLabel: String
    
    var body: some View {
        HStack {
            
            Spacer()
            
            Button {
                cancelAction()
            } label: {
                Text(cancelLabel)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
            }.padding()
            
            Button {
                saveAction()
            } label: {
                Text(saveLabel)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                
            }.padding()
            
        }.padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5))
        
    }
}
