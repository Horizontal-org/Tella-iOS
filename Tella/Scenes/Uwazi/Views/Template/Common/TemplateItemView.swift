//
//  TemplateItemView.swift
//  Tella
//
//  Created by Gustavo on 03/08/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct TemplateItemView: View {
    
    @EnvironmentObject var sheetManager: SheetManager
    @Binding var templateItemViewModel: TemplateItemViewModel
    
    var body: some View {
        HStack {
            if(templateItemViewModel.isDownloaded) {
                Image(.reportSubmitted)
                    .padding(.horizontal, .extraSmall)
            }
            
            CustomText(templateItemViewModel.name, style: .body1Style)
                .padding(.horizontal, .extraSmall)

            Spacer()
            
            if(!templateItemViewModel.isDownloaded) {
                ImageButtonView(imageName: .templateAdd ,
                               action: {
                    templateItemViewModel.downloadTemplate()
                    
//                    let message = String.init(format: LocalizableUwazi.uwaziAddTemplateSavedToast.localized, templateItemViewModel.name)
//                    Toast.displayToast(message:message)
                })
            } else {
                ImageButtonView(imageName: .reportsMore, action: {
                    showTemplateActionBottomSheet()
                }).padding(.trailing, 8)
            }
            
        }.padding(.all, 4)
    }
    
    private func showTemplateActionBottomSheet() {
        sheetManager.showBottomSheet() {
            ActionListBottomSheet(items: templateActionItems,
                                  headerTitle: templateItemViewModel.name ,
                                  action:  {item in
                self.sheetManager.hide()
                self.templateItemViewModel.deleteTemplate()
                let message = String.init(format: LocalizableUwazi.uwaziDeletedToast.localized, templateItemViewModel.name)
                Toast.displayToast(message: message)
            })
        }
    }
    
}
