//
//  TemplateCardView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TemplateCardView: View {
    @EnvironmentObject var sheetManager: SheetManager
    @EnvironmentObject var mainAppModel: MainAppModel
    var templateCardViewModel: TemplateCardViewModel
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                showtemplateActionBottomSheet()
            }) {
                HStack {
//                    MoreButtonView(imageName: "uwazi.star", action: {
//                        //add this template to favorite
//                    })
                    ConnectionCardDetail(title: templateCardViewModel.translatedName, subtitle: templateCardViewModel.serverName)
                    Spacer()
                    MoreButtonView(imageName: "reports.more", action: {
                        //show detail
                        showtemplateActionBottomSheet()
                    })
                }
                .padding(.all, 16)
            }
        }
        .background(Color.white.opacity(0.08))
        .cornerRadius(15)
        .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
    }
    
    private func showtemplateActionBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: downloadTemplateActionItems,
                                  headerTitle: templateCardViewModel.translatedName,
                                  action:  {item in
                let type = item.type as? DownloadedTemplateActionType
                if type == .delete {
                    showDeleteTemplateConfirmationView()
                } else {
                    navigateTo(destination: CreateEntityView(
                        appModel: mainAppModel,
                        templateId: templateCardViewModel.id!,
                        serverId: templateCardViewModel.serverId
                    ).environmentObject(sheetManager))
                                        sheetManager.hide()
                }
            })
        }
    }

    private func showDeleteTemplateConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            let titleText = LocalizableReport.viewModelDelete.localized + " " + "\"\(templateCardViewModel.translatedName)\""
            return ConfirmBottomSheet(titleText: titleText,
                                      msgText: LocalizableUwazi.uwaziDeleteTemplateExpl.localized,
                                      cancelText: LocalizableReport.deleteCancel.localized,
                                      actionText: LocalizableReport.deleteConfirm.localized) {
                templateCardViewModel.deleteTemplate()
                Toast.displayToast(message: "“\(templateCardViewModel.translatedName)” \(LocalizableUwazi.uwaziDeleteEntitySheetExpl.localized)")
            }
        }
    }
}


