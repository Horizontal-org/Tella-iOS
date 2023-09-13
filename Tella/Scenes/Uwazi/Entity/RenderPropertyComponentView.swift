//
//  RenderPropertyComponentView.swift
//  Tella
//
//  Created by Gustavo on 07/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RenderPropertyComponentView: View {
    @EnvironmentObject var entityViewModel : DraftUwaziEntity
    @StateObject var prompt: UwaziEntryPrompt
    var geometry : GeometryProxy
    
    var body: some View {
        GenericEntityWidget(title: prompt.question) {
            renderPropertyComponent(
                prompt: prompt
            )
        }
    }
    @ViewBuilder
    private func renderPropertyComponent(prompt: UwaziEntryPrompt) -> some View {
        switch UwaziEntityPropertyType(rawValue: prompt.type) {
        case .dataTypeText, .dataTypeNumeric:
            UwaziTextWidget(value: prompt.value)
            .environmentObject(prompt)
        case .dataTypeDate, .dataTypeDateRange, .dataTypeMultiDate, .dataTypeMultiDateRange:
            Text(prompt.question)
        case .dataTypeSelect, .dataTypeMultiSelect:
            UwaziSelectWidget(value: prompt.value)
                .environmentObject(prompt)
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
