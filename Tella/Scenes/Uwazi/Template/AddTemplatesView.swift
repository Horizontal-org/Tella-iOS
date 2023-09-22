//
//  AddTemplatesView.swift
//  Tella
//
//  Created by Gustavo on 03/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct AddTemplatesView: View {
    var downloadTemplateAction : (inout CollectedTemplate) -> Void
    @EnvironmentObject var uwaziTemplateViewModel: UwaziTemplateViewModel
    @EnvironmentObject var sheetManager: SheetManager

    var body: some View {
        ContainerView {
            ZStack {
                VStack {
                    headerView()
                    if !self.uwaziTemplateViewModel.isLoading {
                        handleListView()
                    }
                    Spacer()
                }.padding(.top, 0)
                if uwaziTemplateViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        // TODO: Remove this line with more appropiate solution
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            LeadingTitleToolbar(title: LocalizableUwazi.uwaziAddTemplateTitle.localized)
            reloadTemplatesButton()
        }
        .onAppear {
            self.uwaziTemplateViewModel.getTemplates()
        }
    }
    fileprivate func reloadTemplatesButton() -> ToolbarItem<(), Button<some View>> {
        return ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                self.uwaziTemplateViewModel.getTemplates()
            } label: {
                Image("arrow.clockwise")
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
    }

    fileprivate func headerView() -> some View {
        return Group {
            Text(LocalizableUwazi.uwaziAddTemplateExpl.localized)
                .foregroundColor(.white) +
            Text(LocalizableUwazi.uwaziAddTemplateSecondExpl.localized)
                .foregroundColor(Styles.Colors.yellow)
        }
        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
        .foregroundColor(.white)
        .padding(.all, 18)
    }

    fileprivate func handleListView() -> some View {
        VStack {
            if uwaziTemplateViewModel.templates.count > 0 {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(uwaziTemplateViewModel.serverName)
                            .font(.custom(Styles.Fonts.semiBoldFontName, size: 16))
                            .foregroundColor(.white)
                            .padding(.all, 14)
                        ForEach(Array(uwaziTemplateViewModel.templates.enumerated()), id: \.element) { index, template in
                            TemplateItemView(
                                template: $uwaziTemplateViewModel.templates[index],
                                isDownloaded: template.isDownloaded ?? false,
                                downloadTemplate: { template in
                                    Toast.displayToast(message: "“\(template.entityRow?.translatedName ?? "")” “\(LocalizableUwazi.uwaziAddTemplateSavedToast.localized)”")
                                    self.downloadTemplateAction(&template)
                                }) { template in
                                    showServerActionBottomSheet(template: template)
                                }
                            if index < (uwaziTemplateViewModel.templates.count - 1) {
                                DividerView()
                            }
                        }
                    }
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(15)
                    .padding(.all, 18)
                    .padding(.top, 0)
                }
            } else {
                EmptyReportView(message: LocalizableUwazi.uwaziAddTemplateEmptydExpl.localized)
            }
        }
    }
    private func showServerActionBottomSheet(template: CollectedTemplate) {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: templateActionItems,
                                  headerTitle: template.entityRow?.translatedName ?? "",
                                  action:  {item in
                self.uwaziTemplateViewModel.handleDeleteActionsForAddTemplate(item : item, template: template) {
                    self.sheetManager.hide()
                }
            })
        }
    }
}

