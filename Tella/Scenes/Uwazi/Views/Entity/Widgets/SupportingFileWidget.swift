//
//  SupportingFileWidget.swift
//  Tella
//
//  Created by Gustavo on 25/10/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SupportingFileWidget: View {
    @ObservedObject var prompt: UwaziFilesEntryPrompt
    @ObservedObject var entityViewModel: UwaziEntityViewModel
    
    init(prompt: UwaziFilesEntryPrompt, entityViewModel: UwaziEntityViewModel) {
        self.prompt = prompt
        self.entityViewModel = entityViewModel
    }
    
    var body: some View {
        VStack {
            
            CustomText(prompt.helpText ?? "",
                       style: .body2Style,
                       color: Color.white.opacity(0.80),
                       fillsWidth: true)

            AddFileBottomSheetView(viewModel: entityViewModel.addFilesViewModel, content: {
                UwaziActionRow(icon: .uwaziAddFiles,
                               title: LocalizableUwazi.uwaziEntitySelectFiles.localized)
            }, moreAction: {
                entityViewModel.addFilesViewModel.shouldShowDocumentsOnly = false
            })
        }
        
        if(prompt.value.count > 0) {
            FileDropdown(files: $prompt.value)
        }
    }
}

