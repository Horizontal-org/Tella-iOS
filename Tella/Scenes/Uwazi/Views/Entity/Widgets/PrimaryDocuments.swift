//
//  PrimaryDocuments.swift
//  Tella
//
//  Created by Gustavo on 25/10/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct PrimaryDocuments: View {
    @ObservedObject var prompt: UwaziFilesEntryPrompt
    @ObservedObject var entityViewModel: UwaziEntityViewModel
    
    init(prompt: UwaziFilesEntryPrompt, entityViewModel: UwaziEntityViewModel) {
        self.prompt = prompt
        self.entityViewModel = entityViewModel
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(prompt.helpText!)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            AddFileBottomSheetView(viewModel:  entityViewModel.addFilesViewModel, content: {
                UwaziSelectFileComponent(title: LocalizableUwazi.uwaziMultiFileWidgetAttachManyPDFFilesSelectTitle.localized)
            }, moreAction: {
                entityViewModel.addFilesViewModel.shouldShowDocumentsOnly = true
            })
            .background(Color.white.opacity(0.08))
            .cornerRadius(15)
            
        }

        FileItems(files: prompt.value)
        
    }
    
}
