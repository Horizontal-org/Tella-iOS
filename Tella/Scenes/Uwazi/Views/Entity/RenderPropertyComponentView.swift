//
//  RenderPropertyComponentView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct RenderPropertyComponentView: View {
    
    var prompt: any UwaziEntryPrompt
    var entityViewModel: UwaziEntityViewModel
    
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
                    UwaziTextWidget(prompt: prompt as! UwaziTextEntryPrompt,
                                    uwaziEntityViewModel: entityViewModel)
                case .dataTypeSelect:
                    UwaziSelectWidget(prompt: prompt as! UwaziSelectEntryPrompt, uwaziEntityViewModel: entityViewModel)
                case .dataTypeMultiFiles:
                    SupportingFileWidget(prompt: prompt as! UwaziFilesEntryPrompt,
                                         entityViewModel: entityViewModel)
                case .dataTypeMultiPDFFiles:
                    PrimaryDocuments(prompt: prompt as! UwaziFilesEntryPrompt,
                                     entityViewModel: entityViewModel)
                case .dataTypeDivider:
                    UwaziDividerWidget()
                case .dataTypeDate:
                    UwaziDatePicker(prompt: prompt as! UwaziTextEntryPrompt,
                                    entityViewModel: entityViewModel)
                case .dataRelationship:
                    UwaziRelationshipWidget(prompt: prompt as! UwaziRelationshipEntryPrompt,
                                            entityViewModel: entityViewModel)
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
        case .dataTypeText, .dataTypeNumeric, .dataTypeSelect, .dataTypeMultiFiles, .dataTypeMultiPDFFiles, .dataTypeDivider, .dataTypeDate, .dataTypeMarkdown, .dataRelationship:
            return true
        default:
            return false
        }
    }
}
