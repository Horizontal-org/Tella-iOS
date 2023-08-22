//
//  TemplateListView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateListView: View {
    @EnvironmentObject var uwaziViewModel : UwaziReportsViewModel
    @EnvironmentObject var sheetManager: SheetManager
    var message : String
    var serverName : String
    
    var body: some View {
        ZStack {
            if uwaziViewModel.downloadedTemplates.count > 0 {
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        Text("These are uwazi templates you can fil out.")
                            .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                            .foregroundColor(.white.opacity(0.64))
                            .padding(.all, 14)
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
                    showDeleteReportConfirmationView(template: template)
                }
            })
        }
    }
    private func showDeleteReportConfirmationView(template: CollectedTemplate) {
        sheetManager.showBottomSheet(modalHeight: 200) {
            DeleteTemplateConfirmationView(title: template.entityRow?.translatedName,
                                         message: "Are you sure you want to delete this Template?") {
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
