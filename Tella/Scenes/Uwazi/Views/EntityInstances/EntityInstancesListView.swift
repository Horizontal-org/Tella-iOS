//
//  EntityInstancesListView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 27/3/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

struct EntityInstancesListView: View {
    
    var message: String
    @Binding var uwaziEntityInstance: [EntityInstanceCardViewModel]
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            Text(message)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                .foregroundColor(.white)
                .padding(.all, 15)
            ScrollView {
                ForEach($uwaziEntityInstance, id: \.id) { itemViewModel in
                    EntityInstanceItemView(instanceItemViewModel: itemViewModel)
                }
            }
        }
    }
}

struct EntityInstanceItemView: View {
    @EnvironmentObject var mainAppModel: MainAppModel

    @EnvironmentObject var sheetManager: SheetManager
    @Binding var instanceItemViewModel: EntityInstanceCardViewModel
    
    var body: some View {
        HStack {
            //            if(instanceItemViewModel.isDownloaded) {
            //                Image("report.submitted")
            //                    .padding(.leading, 8)
            //            }
            
            ConnectionCardDetail(title: instanceItemViewModel.title,
                                 subtitle: instanceItemViewModel.serverName)
            
            Spacer()
            
            MoreButtonView(imageName: "reports.more", action: {
                showtemplateActionBottomSheet()
            })
        }.padding(.all, 16)
        
            .background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
        
    }
    
    
    private func showtemplateActionBottomSheet() {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: uwaziDraftActionItems,
                                  headerTitle: instanceItemViewModel.title,
                                  action:  {item in
                let type = item.type as? DownloadedTemplateActionType
                if type == .delete {
                    showDeleteTemplateConfirmationView()
                } else {
                    navigateTo(destination: CreateEntityView(
                        appModel: mainAppModel,
                        templateId: instanceItemViewModel.templateId,
//                        serverId: instanceItemViewModel.serverId,
                        entityInstanceID: instanceItemViewModel.id
                    ).environmentObject(sheetManager))
                    sheetManager.hide()
                }
            })
        }
    }
    
    private func showDeleteTemplateConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            let titleText = LocalizableUwazi.deleteDraftSheetTitle.localized + " " + "\"\(instanceItemViewModel.title)\""
            return ConfirmBottomSheet(titleText: titleText,
                                      msgText: LocalizableUwazi.deleteDraftSheetExpl.localized,
                                      cancelText: LocalizableUwazi.noSheetAction.localized,
                                      actionText: LocalizableUwazi.yesSheetAction.localized) {
                instanceItemViewModel.deleteTemplate()
                // to ask
//                Toast.displayToast(message: "“\(templateCardViewModel.translatedName)” \(LocalizableUwazi.uwaziDeleteEntitySheetExpl.localized)")
            }
        }
    }
}
