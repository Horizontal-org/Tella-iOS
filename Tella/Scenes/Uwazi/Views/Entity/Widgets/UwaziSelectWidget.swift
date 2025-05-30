//
//  UwaziSelectWidget.swift
//  Tella
//
//  Created by Gustavo on 23/10/2023.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziSelectWidget: View {
    
    @State private var shouldShowMenu : Bool = false
    @ObservedObject var prompt: UwaziSelectEntryPrompt
    var uwaziEntityViewModel : UwaziEntityViewModel
    
    var body: some View {
        Button {
            DispatchQueue.main.async {
                shouldShowMenu.toggle()
            }
            
        } label: {
            SelectWidgetButton(title: selectTitle(), shouldShowMenu: shouldShowMenu)
        }.background(Color.white.opacity(0.08))
            .cornerRadius(12)
        
        if shouldShowMenu {
            SelectListOptions(shouldShowMenu: $shouldShowMenu,
                              prompt: prompt,
                              uwaziEntityViewModel: uwaziEntityViewModel)
        }
    }
    
    func selectTitle() -> String {
        guard
            let selectedId = prompt.value.first,
            let selectValues = prompt.selectValues
        else {
            return "Select"
        }
        
        if let nestedMatch = selectValues
            .compactMap({ $0.values })
            .flatMap({ $0 })
            .first(where: { $0.id == selectedId }) {
            return nestedMatch.label
        }
        
        if let topLevelMatch = selectValues.first(where: { $0.id == selectedId }) {
            return topLevelMatch.label
        }
        
        return "Select"
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
            
            Image(shouldShowMenu ? .selectArrowUp : .reportsArrowDown)
                .padding()
        }
    }
}

struct SelectListOptions: View {
    @Binding var shouldShowMenu: Bool
    var prompt: UwaziSelectEntryPrompt
    var uwaziEntityViewModel : UwaziEntityViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(prompt.selectValues ?? [], id: \.self) { selectedOptions in
                        listView(selectedOptions:selectedOptions)
                    }
                }
            }
            .frame(minHeight: 40, maxHeight: 200)
            .background(Styles.Colors.backgroundMain)
            .cornerRadius(12)
            
            Spacer()
        }
        .background(Color.clear)
    }
    
    @ViewBuilder
    func listView(selectedOptions:SelectValues) -> some View {
        if let values = selectedOptions.values, !values.isEmpty {
            
            titleOptionRow(selectedOption: selectedOptions)
            
            ForEach(selectedOptions.values ?? [], id: \.self) { value in
                selectOptionButton(selectedOption: value,
                                   leadingPadding: 20)
            }
            
        } else {
            selectOptionButton(selectedOption: selectedOptions)
        }
    }
    
    func titleOptionRow(selectedOption: SelectValues) -> some View {
        Text(selectedOption.label)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            .padding(.all, 14)
            .background(Color.white.opacity(0.08))
    }
    
    func selectOptionButton(selectedOption: SelectValues,
                            leadingPadding: CGFloat = 0) -> some View {
        
        Button(action: {
            shouldShowMenu = false
            prompt.value = [selectedOption.id]
            entityViewModel.publishUpdates()
        }) {
            Text(selectedOption.label)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.all, 14)
        }
        .padding(.leading, leadingPadding)
        .background(prompt.value.first == selectedOption.id ?  Color.white.opacity(0.16) : Color.white.opacity(0.08))
    }
    
}
