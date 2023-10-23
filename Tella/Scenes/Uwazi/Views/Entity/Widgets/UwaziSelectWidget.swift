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
    @State var value: UwaziValue
    var body: some View {
        Button {
            DispatchQueue.main.async {
                shouldShowMenu = true
            }

        } label: {
            SelectWidgetButton(title: selectTitle(value: value.stringValue))
        }.background(Color.white.opacity(0.08))
            .cornerRadius(12)

        if shouldShowMenu {
            SelectListOptions(prompt: prompt, shouldShowMenu: $shouldShowMenu, value: $value)
        }
    }

    func selectTitle(value: String) -> String {
        return value.isEmpty ? "Select" : value
    }
}

struct SelectWidgetButton: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white.opacity(0.87))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            Image("reports.arrow-down")
                .padding()
        }
    }
}

struct SelectListOptions: View {
    var prompt: UwaziEntryPrompt
    @Binding var shouldShowMenu: Bool
    @Binding var value: UwaziValue

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(prompt.selectValues ?? [], id: \.self) { selectedOptions in
                        SelectOptionButton(
                            selectedOption: selectedOptions,
                            shouldShowMenu: $shouldShowMenu,
                            value: $value
                        )
                    }
                }
                .frame(minHeight: 40, maxHeight: 250)
                .background(Styles.Colors.backgroundMain)
                .cornerRadius(12)
            }
            Spacer()
        }
        .padding()
        .background(Color.clear)
    }
}

struct SelectOptionButton: View {
    let selectedOption: SelectValue
    @Binding var shouldShowMenu: Bool
    @Binding var value: UwaziValue

    var body: some View {
        Button(action: {
            shouldShowMenu = false
            value.selectedValue = [selectedOption]
            value.stringValue = selectedOption.translatedLabel ?? ""
        }) {
            Text(selectedOption.translatedLabel ?? "")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .padding(.all, 14)
        }
        .background(Color.white.opacity(0.08))
    }
}
