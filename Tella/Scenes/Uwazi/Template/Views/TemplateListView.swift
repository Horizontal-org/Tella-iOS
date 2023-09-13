//
//  TemplateListView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateListView: View {
    @EnvironmentObject var uwaziViewModel : UwaziTemplateViewModel
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var mainAppModel: MainAppModel
    var message : String
    var serverName : String
    
    var body: some View {
        ZStack {
            if !uwaziViewModel.downloadedTemplates.isEmpty {
                VStack(alignment: .center, spacing: 0) {
                    Text(LocalizableUwazi.uwaziTemplateListExpl.localized)
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                        .foregroundColor(.white.opacity(0.64))
                        .padding(.all, 14)
                    ScrollView {
                        ForEach($uwaziViewModel.downloadedTemplates, id: \.self) { template in
                            TemplateCardView(template: template, serverName: serverName) { template in
                                self.showtemplateActionBottomSheet(template: template)
                            }
                        }
                    }
                }
            } else {
                EmptyReportView(message: message)
            }
        }
        .onAppear {
            self.uwaziViewModel.getDownloadedTemplates()
        }
    }

    private func showtemplateActionBottomSheet(template: CollectedTemplate) {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: downloadTemplateActionItems,
                                  headerTitle: template.entityRow?.translatedName ?? "",
                                  action:  {item in
                let type = item.type as? DownloadedTemplateActionType
                if type == .delete {
                    showDeleteTemplateConfirmationView(template: template)
                } else {
                    navigateToCreateEntityView(template: template)
                    sheetManager.hide()
                }
            })
        }
    }

    private func navigateToCreateEntityView(template: CollectedTemplate) {
        navigateTo(destination:
                    CreateEntityView(mainAppModel: mainAppModel, template: template)
            .environmentObject(sheetManager)

        )
    }
    private func showDeleteTemplateConfirmationView(template: CollectedTemplate) {
        sheetManager.showBottomSheet(modalHeight: 200) {
            DeleteTemplateConfirmationView(title: template.entityRow?.translatedName,
                                           message: LocalizableUwazi.uwaziDeleteTemplateExpl.localized) {
                if let templateId = template.id {
                    self.uwaziViewModel.deleteDownloadedTemplate(templateId: templateId)
                }
                
            }
        }
    }
}

struct TemplateListView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateListView( message: "", serverName: "")
    }
}
