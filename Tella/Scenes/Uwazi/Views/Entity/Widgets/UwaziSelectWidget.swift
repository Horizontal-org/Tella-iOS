//
//  UwaziSelectWidget.swift
//  Tella
//
//  Created by Gustavo on 23/10/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziSelectWidget: View {
    
    @State private var shouldShowMenu : Bool = false
    @ObservedObject var prompt: UwaziSelectEntryPrompt
    
    var body: some View {
        Button {
            DispatchQueue.main.async {
                shouldShowMenu = true
            }
            
        } label: {
            SelectWidgetButton(title: selectTitle(), shouldShowMenu: shouldShowMenu)
        }.background(Color.white.opacity(0.08))
            .cornerRadius(12)
        
        if shouldShowMenu {
            SelectListOptions(shouldShowMenu: $shouldShowMenu, prompt: prompt)
        }
    }
    
    func selectTitle() -> String {
        guard let item = prompt.selectValues?.filter({$0.id == prompt.values.first?.value}).first else {return "Select"}
        return item.translatedLabel ?? ""
    }
}

struct SelectWidgetButton: View {
    let title: String
    let shouldShowMenu: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white.opacity(0.87))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if(shouldShowMenu) {
                Image("select.arrow.up")
                    .padding()
            } else {
                Image("reports.arrow-down")
                    .padding()
            }
        }
    }
}

struct SelectListOptions: View {
    @Binding var shouldShowMenu: Bool
    var prompt: UwaziSelectEntryPrompt
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(prompt.selectValues ?? [], id: \.self) { selectedOptions in
                        SelectOptionButton(
                            selectedOption: selectedOptions,
                            shouldShowMenu: $shouldShowMenu,
                            prompt: prompt
                        )
                    }
                }
                .frame(minHeight: 40, maxHeight: 250)
                .background(Styles.Colors.backgroundMain)
                .cornerRadius(12)
            }
            Spacer()
        }
        .background(Color.clear)
    }
}

struct SelectOptionButton: View {
    let selectedOption: SelectValue
    @Binding var shouldShowMenu: Bool
    var prompt: UwaziSelectEntryPrompt
    @EnvironmentObject  var uwaziEntityViewModel : UwaziEntityViewModel
    
    var body: some View {
        Button(action: {
            shouldShowMenu = false
            guard let id = selectedOption.id else { return }
            prompt.values = [UwaziValue(value: id,label: selectedOption.label)]
            uwaziEntityViewModel.publishUpdates()
        }) {
            Text(selectedOption.translatedLabel ?? "")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.all, 14)
        }
        .background(prompt.values.first?.value == selectedOption.id ?  Color.white.opacity(0.16) : Color.white.opacity(0.08))
    }
}
