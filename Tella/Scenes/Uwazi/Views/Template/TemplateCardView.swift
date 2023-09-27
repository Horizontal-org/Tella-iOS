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
    var templateCardViewModel: TemplateCardViewModel
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                MoreButtonView(imageName: "uwazi.star", action: {
                    //add this template to favorie
                })
                ConnectionCardDetail(title: templateCardViewModel.translatedName, subtitle: templateCardViewModel.serverName)
                Spacer()
                MoreButtonView(imageName: "reports.more", action: {
                    //show detail
                    showtemplateActionBottomSheet()
                })
            }.padding(.all, 16)
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
                }
            })
        }
    }

    private func showDeleteTemplateConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            let deleteViewModel = DeleteTemplateConfirmationViewModel(title: templateCardViewModel.translatedName,
                                                                      message: LocalizableUwazi.uwaziDeleteTemplateExpl.localized,
                                                                      confirmAction: {
                templateCardViewModel.deleteTemplate
            })
            return DeleteTemplateConfirmationView(viewModel: deleteViewModel)
        }
    }
}


