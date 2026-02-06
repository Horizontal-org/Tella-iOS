//
//  SubmitEntityView.swift
//  Tella
//
//  Created by Gustavo on 06/11/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SummaryEntityView: View {
    
    @StateObject var summaryViewModel : SummaryViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(mainAppModel: MainAppModel,
         entityInstance: UwaziEntityInstance? = nil,
         entityInstanceId: Int? = nil) {
        _summaryViewModel = StateObject(wrappedValue: SummaryViewModel(mainAppModel: mainAppModel,
                                                                       entityInstance: entityInstance,
                                                                       entityInstanceId:entityInstanceId))
    }
    var body: some View {
        ZStack {
            
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            
            if summaryViewModel.isLoading {
                CircularActivityIndicatory()
            }
        }
        .onReceive(summaryViewModel.$shouldHideView, perform: { shouldHideView in
            if shouldHideView {
                dismissViews()
            }
        })
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: LocalizableUwazi.uwaziEntitySummaryDetailToolbarItem.localized)
    }
    
    var contentView: some View {
        VStack {
            entityContentView
            
            if summaryViewModel.shouldHideBottomActionView {
                UwaziDividerWidget()
                bottomActionView
            }
        }
    }
    
    var entityContentView: some View {
        VStack {
            templateData
            
            UwaziDividerWidget()
            
            Spacer()
                .frame(height: 20)
            
            entityTitle
            
            entityFilesView
            
            Spacer()
        }.scrollOnOverflow()
    }
    
    var templateData: some View {
        VStack {
            Text(summaryViewModel.serverName)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(summaryViewModel.templateName)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding()
    }
    
    var entityTitle: some View {
        VStack {
            Text(summaryViewModel.entityTitle)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
    
    var entityFilesView: some View {
        VStack {
            entityResponseItem
            UwaziFileItems(files: summaryViewModel.uwaziVaultFiles)
        }           .padding(.horizontal, 16)
        
    }
    
    var bottomActionView: some View {
        HStack {
            
            
            TellaButtonView(title: "SUBMIT LATER",
                                      nextButtonAction: .action,
                                      buttonType: .clear,
                                      isValid: .constant(true)) {
                
                
                summaryViewModel.submitLater()
            }
            
            Spacer()
            
            TellaButtonView(title: "SUBMIT",
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: .constant(true)) {
                
                summaryViewModel.submitEntity()
                
            }
            
        }.padding(.horizontal)
    }
    
    var entityResponseItem: some View {
        
        VaultFileItemView(file: VaultFileItemViewModel(image: AnyView(Image("document")),
                                                       name: LocalizableUwazi.uwaziEntitySummaryDetailEntityResponseTitle.localized,
                                                       size: summaryViewModel.getEntityResponseSize()))
        .padding(.bottom, 17)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func dismissViews() {
        self.popTo(ViewClassType.uwaziView)
    }
}


struct UwaziFileItems: View {
    
    var files: [UwaziVaultFile]
    
    var body: some View {
        VStack {
            ForEach(files.sorted{$0.created < $1.created}, id: \.id) { file in
                VaultFileItemView(file: VaultFileItemViewModel(image: file.listImage,
                                                               name: file.name,
                                                               size: file.size.getFormattedFileSize(),
                                                               iconName: file.statusIcon))
                .padding(.bottom, 17)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
