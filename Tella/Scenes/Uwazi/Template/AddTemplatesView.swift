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
    var deleteTemplateAction: (CollectedTemplate) -> Void
    @EnvironmentObject var uwaziReportsViewModel: UwaziReportsViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        ContainerView {
            ZStack {
                VStack {
                    Group {
                        Text("These are the templates available on the Uwazi instances you are connected to. You can")
                            .foregroundColor(.white) +
                        Text(" manage your Uwazi instances here.")
                            .foregroundColor(Styles.Colors.yellow)
                    }
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                        .foregroundColor(.white)
                        .padding(.all, 18)
                        if !self.uwaziReportsViewModel.isLoading {
                            if uwaziReportsViewModel.templates.count > 0 {
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(uwaziReportsViewModel.serverName)
                                            .font(.custom(Styles.Fonts.boldFontName, size: 18))
                                            .foregroundColor(.white)
                                            .padding(.all, 14)
                                        ForEach(Array(uwaziReportsViewModel.templates.enumerated()), id: \.element) { index, template in
                                            TemplateItemView(
                                                template: $uwaziReportsViewModel.templates[index],
                                                serverName: uwaziReportsViewModel.serverName,
                                                isDownloaded: template.isDownloaded == 1 ? true : false,
                                                downloadTemplate: { template in
                                                    Toast.displayToast(message: "“\(template.entityRow?.translatedName ?? "")” successfully added to your Uwazi templates.")
                                                    self.downloadTemplateAction(&template)
                                                }) { template in
                                                    showServerActionBottomSheet(template: template)
                                                }

                                            if index < (uwaziReportsViewModel.templates.count - 1) {
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
                                EmptyReportView(message: "There are no templates")
                            }
                        }
                    Spacer()
                }.padding(.top, 0)


                if uwaziReportsViewModel.isLoading {
                    CircularActivityIndicatory()
                }
            }
        }
        // TODO: Remove this line with more appropiate solution
        .navigationBarTitle("", displayMode: .inline)
        
        .toolbar {
            LeadingTitleToolbar(title: "Add templates")
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    self.uwaziReportsViewModel.getTemplates()
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            self.uwaziReportsViewModel.getTemplates()
        }
    }
    private func showServerActionBottomSheet(template: CollectedTemplate) {
        sheetManager.showBottomSheet(modalHeight: 176) {
            ActionListBottomSheet(items: templateActionItems,
                                  headerTitle: template.entityRow?.translatedName ?? "",
                                  action:  {item in

                self.uwaziReportsViewModel.handleActions(item : item, template: template) {
                    self.sheetManager.hide()
                }
            })
        }
    }
}

