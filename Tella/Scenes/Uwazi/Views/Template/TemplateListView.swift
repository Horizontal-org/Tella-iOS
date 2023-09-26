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
                            let cardViewModel = createCardViewModel(template)
                            TemplateCardView(viewModel: cardViewModel)
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

    fileprivate func createCardViewModel(_ template: Binding<CollectedTemplate>) -> TemplateCardViewModel {
        return TemplateCardViewModel(serverName: template.serverName.wrappedValue ?? "",
                                     translatedName: template.entityRow.wrappedValue?.translatedName ?? "") {
            self.showDeleteTemplateConfirmationView(template: template.wrappedValue)
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
                }
            })
        }
    }
    
    private func showDeleteTemplateConfirmationView(template: CollectedTemplate) {
        sheetManager.showBottomSheet(modalHeight: 200) {
            let deleteViewModel = DeleteTemplateConfirmationViewModel(title: template.entityRow?.translatedName ?? "",
                                                                      message: LocalizableUwazi.uwaziDeleteTemplateExpl.localized,
                                                                      confirmAction: {
                if let templateId = template.id {
                    self.uwaziViewModel.deleteDownloadedTemplate(templateId: templateId)
                }
            })
            return DeleteTemplateConfirmationView(viewModel: deleteViewModel)
        }
    }
}

struct TemplateListView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateListView( message: "", serverName: "")
    }
}
