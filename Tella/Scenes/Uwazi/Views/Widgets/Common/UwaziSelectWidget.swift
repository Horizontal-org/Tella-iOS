//
//  UwaziSelectWidget.swift
//  Tella
//
//  Created by Gustavo on 12/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziSelectWidget: View {
    @State private var shouldShowMenu : Bool = false
    @EnvironmentObject var prompt: UwaziEntryPrompt
    @State var value: UwaziValue
    var body: some View {
        Button {
            DispatchQueue.main.async {
                shouldShowMenu = true
            }
            
        } label: {
            HStack {
                Text(selectTitle(value:value.stringValue))
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white.opacity(0.87))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("reports.arrow-down")
                    .padding()
                
            }
        }.background(Color.white.opacity(0.08))
            .cornerRadius(12)
        
        if shouldShowMenu {
            selectListOptions
        }
    }
    
    func selectTitle(value: String) -> String {
        return value.isEmpty ? "Select" : value
    }
    @ViewBuilder
    var selectListOptions: some View {

            VStack {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(prompt.selectValues ?? [], id: \.self) { selectedOptions in
                            Button {
                                shouldShowMenu = false
                                prompt.value.selectedValue = [selectedOptions]
                                prompt.value.stringValue = selectedOptions.translatedLabel ?? ""
                            } label: {
                                Text(selectedOptions.translatedLabel ?? "")
                                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .padding(.all, 14)
                            }.background(Color.white.opacity(0.08))
                        }
                    }.frame(minHeight: 40, maxHeight: 250)
                        .background(Styles.Colors.backgroundMain)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()

            .background(Color.clear)
    }
}
