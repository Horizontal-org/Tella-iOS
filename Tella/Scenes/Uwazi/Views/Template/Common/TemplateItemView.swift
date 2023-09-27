//
//  TemplateItemView.swift
//  Tella
//
//  Created by Gustavo on 03/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateItemView: View {
    
    @EnvironmentObject var sheetManager: SheetManager
    var templateItemViewModel: TemplateItemViewModel
    
    internal init(templateItemViewModel: TemplateItemViewModel) {
        self.templateItemViewModel = templateItemViewModel
    }
    
    var body: some View {
        HStack {
            if(templateItemViewModel.isDownloaded) {
                Image("report.submitted")
                    .padding(.leading, 8)
            }
            Text(templateItemViewModel.name)
                .font(.custom(Styles.Fonts.regularFontName, size: 16))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
            
            Spacer()
            
            if(!templateItemViewModel.isDownloaded) {
                MoreButtonView(imageName: "template.add", 
                               action: templateItemViewModel.downloadTemplate)
            } else {
                MoreButtonView(imageName: "reports.more", action: {
                    showTemplateActionBottomSheet()
                }).padding(.trailing, 8)
            }
            
        }.padding(.all, 4)
    }
    
    private func showTemplateActionBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: templateActionItems,
                                  headerTitle: templateItemViewModel.name ,
                                  action:  {item in
                self.sheetManager.hide()
                 self.templateItemViewModel.deleteTemplate()
            })
        }
    }
    
}
