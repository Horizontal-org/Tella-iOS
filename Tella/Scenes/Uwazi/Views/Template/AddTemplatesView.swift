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
    @EnvironmentObject var uwaziTemplateViewModel: AddTemplateViewModel
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
            headerView()
            if !self.uwaziTemplateViewModel.isLoading {
                handleListView()
            }
            Spacer()
        }.padding(.top, 0)
    }
    
    fileprivate func headerView() -> some View {
        let firstPart = Text(LocalizableUwazi.uwaziAddTemplateExpl.localized)
            .foregroundColor(.white)
        let secondPart = Text(LocalizableUwazi.uwaziAddTemplateSecondExpl.localized)
            .foregroundColor(Styles.Colors.yellow)
        
        return Group {
            HStack {
                firstPart + secondPart
            }
            .onTapGesture {
                navigateTo(destination: ServersListView().environmentObject(ServersViewModel(mainAppModel: uwaziTemplateViewModel.mainAppModel)))
            }
        }
        .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
        .padding(.all, 18)
    }
    
    fileprivate func handleListView() -> some View {
        VStack {
            if uwaziTemplateViewModel.templateItemsViewModel.count > 0 {
                Text("")
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(uwaziTemplateViewModel.serverName)
                            .font(.custom(Styles.Fonts.semiBoldFontName, size: 16))
                            .foregroundColor(.white)
                            .padding(.all, 14)
                        ForEach($uwaziTemplateViewModel.templateItemsViewModel, id: \.id) { itemViewModel in
                            TemplateItemView(templateItemViewModel: itemViewModel)
                            if itemViewModel.wrappedValue.id != (uwaziTemplateViewModel.templateItemsViewModel.last?.id ?? "") {
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

