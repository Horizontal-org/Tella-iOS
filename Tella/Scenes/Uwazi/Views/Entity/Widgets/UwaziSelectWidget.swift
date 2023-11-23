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
    @EnvironmentObject var prompt: UwaziEntryPrompt
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    @ObservedObject var value: UwaziValue
    var body: some View {
        Button {
            DispatchQueue.main.async {
                shouldShowMenu = true
            }

        } label: {
            SelectWidgetButton(title: selectTitle(value: value.stringValue), shouldShowMenu: shouldShowMenu)
        }.background(Color.white.opacity(0.08))
            .cornerRadius(12)

        if shouldShowMenu {
            SelectListOptions(prompt: prompt, shouldShowMenu: $shouldShowMenu, value: value).environmentObject(entityViewModel)
        }
    }

    func selectTitle(value: String) -> String {
        return value.isEmpty ? "Select" : value
    }
}

struct SelectWidgetButton: View {
    let title: String
    let shouldShowMenu: Bool
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
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
    var prompt: UwaziEntryPrompt
    @Binding var shouldShowMenu: Bool
    @ObservedObject var value: UwaziValue
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(prompt.selectValues ?? [], id: \.self) { selectedOptions in
                        SelectOptionButton(
                            selectedOption: selectedOptions,
                            promptId: prompt.id ?? "",
                            shouldShowMenu: $shouldShowMenu,
                            value: value
                        ).environmentObject(entityViewModel)
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
    var promptId: String
    @Binding var shouldShowMenu: Bool
    @ObservedObject var value: UwaziValue
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    var body: some View {
        Button(action: {
            shouldShowMenu = false
            value.selectedValue = [selectedOption]
            value.stringValue = selectedOption.translatedLabel ?? ""
            entityViewModel.toggleShowClear(forId: promptId, value: true)
        }) {
            Text(selectedOption.translatedLabel ?? "")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.all, 14)
        }
        .background(value.stringValue == selectedOption.translatedLabel ?  Color.white.opacity(0.16) : Color.white.opacity(0.08))
    }
}
