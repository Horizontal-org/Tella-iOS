//
//  AddTemplatesView.swift
//  Tella
//
//  Created by Gustavo on 03/08/2023.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct AddTemplatesView: View {
    @ObservedObject var uwaziTemplateViewModel: AddTemplateViewModel
    @EnvironmentObject var sheetManager: SheetManager
    
    var body: some View {
        
        ZStack {
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            
            if uwaziTemplateViewModel.isLoading {
                CircularActivityIndicatory()
            }
        }
        .onAppear {
            self.uwaziTemplateViewModel.getTemplates()
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableUwazi.uwaziAddTemplateTitle.localized,
                             rightButtonType: .reload,
                             rightButtonAction: { self.uwaziTemplateViewModel.getTemplates() })
    }
    
    var contentView: some View {
        VStack {
            CustomText(LocalizableUwazi.uwaziAddTemplateExpl.localized, style: .body1Style)
                .padding(.all, .extraNormal)
            
            if !self.uwaziTemplateViewModel.isLoading {
                handleListView()
            }
            Spacer()
        }.padding(.top, 0)
    }
    
    fileprivate func handleListView() -> some View {
        VStack {
            if uwaziTemplateViewModel.templateItemsViewModel.count > 0 {

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        CustomText(uwaziTemplateViewModel.serverName, style: .subheading1Style)
                            .padding(.all, .normal)

                        ForEach($uwaziTemplateViewModel.templateItemsViewModel, id: \.id) { itemViewModel in
                            TemplateItemView(templateItemViewModel: itemViewModel)
                            if itemViewModel.wrappedValue.id != (uwaziTemplateViewModel.templateItemsViewModel.last?.id ?? "") {
                                DividerView()
                            }
                        }
                    }
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(.smallCornerRadius)
                    .padding(.all, .extraNormal)
                    .padding(.top, 0)
                }
            } else {
                Group {
                    Spacer()
                    ConnectionEmptyView(message: LocalizableUwazi.uwaziAddTemplateEmptydExpl.localized, iconName: ServerConnectionType.uwazi.emptyIcon)
                    Spacer()
                }
            }
        }
        .onReceive(uwaziTemplateViewModel.$showToast, perform: { showToast in
            if showToast {
                Toast.displayToast(message: uwaziTemplateViewModel.toastMessage)
            }
        })
    }
}

