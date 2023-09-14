//
//  RenderPropertyComponentView.swift
//  Tella
//
//  Created by Gustavo on 07/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RenderPropertyComponentView: View {
    @StateObject var prompt: UwaziEntryPrompt
    var body: some View {
        GenericEntityWidget(isRequired: prompt.required ?? false,
                            showClearButton: ableToClearData(),
                            prompt: prompt) {
            renderPropertyComponent()
        }.padding(.vertical, 20)
    }
    @ViewBuilder
    private func renderPropertyComponent() -> some View {
        switch UwaziEntityPropertyType(rawValue: prompt.type) {
        case .dataTypeText, .dataTypeNumeric:
            UwaziTextWidget(value: prompt.value)
        case .dataTypeDate, .dataTypeDateRange, .dataTypeMultiDate, .dataTypeMultiDateRange:
            UwaziDateWidget(prompt: prompt)
        case .dataTypeSelect, .dataTypeMultiSelect:
            Text(prompt.question)
        case .dataTypeLink:
            Text(prompt.question)
        case .dataTypeImage:
            Text(prompt.question)
        case .dataTypeGeolocation:
            Text(prompt.question)
        case .dataTypePreview:
            Text(prompt.question)
        case .dataTypeMedia:
            Text(prompt.question)
        case .dataTypeMarkdown:
            Text(prompt.question)
        case .dataTypeMultiFiles, .dataTypeMultiPDFFiles:
            Text(prompt.question)
        case .dataTypeGeneratedID:
            Text(prompt.question)
        default:
            Group {
                Text("Unsupported property type")
            }
        }
    }
}
extension RenderPropertyComponentView {
    func ableToClearData() -> Bool {
        switch UwaziEntityPropertyType(rawValue: prompt.type) {
        case .dataTypeDate:
            return true
        default:
            return false
        }
    }
}
