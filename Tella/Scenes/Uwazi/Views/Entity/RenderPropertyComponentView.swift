//
//  RenderPropertyComponentView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RenderPropertyComponentView: View {
    
    var prompt: any UwaziEntryPrompt
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    
    var body: some View {
        
        if shouldRenderPrompt(forType: prompt.type.rawValue) {
            VStack() {
                
                UwaziEntityTitleView(title: prompt.question,
                                     isRequired: prompt.required ?? false,
                                     showClear: prompt.showClear,
                                     onClearAction: {
                    prompt.empty()
                    entityViewModel.publishUpdates()
                })
                
                switch prompt.type {
                case .dataTypeText, .dataTypeNumeric, .dataTypeMarkdown:
                    UwaziTextWidget(prompt: prompt as! UwaziTextEntryPrompt)
                case .dataTypeSelect, .dataTypeMultiSelect:
                    UwaziSelectWidget(prompt: prompt as! UwaziSelectEntryPrompt)
                case .dataTypeMultiFiles:
                    SupportingFileWidget(prompt: prompt as! UwaziFilesEntryPrompt)
                case .dataTypeMultiPDFFiles:
                    PrimaryDocuments(prompt: prompt as! UwaziFilesEntryPrompt)
                case .dataTypeDivider:
                    UwaziDividerWidget()
                case .dataTypeDate:
                    UwaziDatePicker()
                case .dataRelationship:
                    UwaziRelationshipWidget()
                        .environmentObject(prompt)
                default:
                    EmptyView()
                }
                
                if(prompt.shouldShowMandatoryError) {
                    UwaziEntityMandatoryTextView()
                }

                
            }.padding(.vertical, 14)
        }
    }
    
    private func shouldRenderPrompt(forType type: String) -> Bool {
        guard let propertyType = UwaziEntityPropertyType(rawValue: type) else { return false }
        
        switch propertyType {
        case .dataTypeText, .dataTypeNumeric, .dataTypeSelect, .dataTypeMultiSelect, .dataTypeMultiFiles, .dataTypeMultiPDFFiles, .dataTypeDivider, .dataTypeDate, .dataTypeMarkdown, .dataRelationship:
            return true
        default:
            return false
        }
    }
}
