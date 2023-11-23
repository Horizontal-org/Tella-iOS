//
//  RenderPropertyComponentView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RenderPropertyComponentView: View {
    @StateObject var prompt: UwaziEntryPrompt
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    
    var body: some View {
        GenericEntityWidget(title: prompt.question,
                            isRequired: prompt.required ?? false,
                            showMandatory: $prompt.showMandatoryError,
                            shouldRender:shouldRenderPrompt(forType: prompt.type),
                            showClear: prompt.showClear ?? false
        ) {
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
        case .dataTypeSelect, .dataTypeMultiSelect:
            UwaziSelectWidget(value: prompt.value)
                .environmentObject(prompt)
                .environmentObject(entityViewModel)
        case .dataTypeMultiFiles:
            SupportingFileWidget()
                .environmentObject(prompt)
                .environmentObject(sheetManager)
                .environmentObject(entityViewModel)
        case .dataTypeMultiPDFFiles:
            PrimaryDocuments()
                .environmentObject(prompt)
                .environmentObject(sheetManager)
                .environmentObject(entityViewModel)
        case .dataTypeDivider:
            UwaziDividerWidget()
        default:
            EmptyView()
        }
    }
    
    private func shouldRenderPrompt(forType type: String) -> Bool {
        guard let propertyType = UwaziEntityPropertyType(rawValue: type) else { return false }
        
        switch propertyType {
        case .dataTypeText, .dataTypeNumeric, .dataTypeSelect, .dataTypeMultiSelect, .dataTypeMultiFiles, .dataTypeMultiPDFFiles, .dataTypeDivider:
            return true
        default:
            return false
        }
    }
}
