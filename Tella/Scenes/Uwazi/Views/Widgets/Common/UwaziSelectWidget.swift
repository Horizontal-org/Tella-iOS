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
    @State private var manuFrame : CGRect = CGRectZero
    @EnvironmentObject var prompt: UwaziEntryPrompt
    var body: some View {
        Button {
            DispatchQueue.main.async {
                shouldShowMenu = true
            }
            
        } label: {
            HStack {
                Text(prompt.question)
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
    
    @ViewBuilder
    var selectListOptions: some View {

            VStack {
                Spacer()
                ScrollView {

                    VStack(spacing: 0) {

                        ForEach(prompt.selectValues ?? [], id: \.self) { selectedOptions in

                            Button {
                                shouldShowMenu = false

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

struct UwaziSelectWidget_Previews: PreviewProvider {
    static var previews: some View {
        UwaziSelectWidget()
    }
}
