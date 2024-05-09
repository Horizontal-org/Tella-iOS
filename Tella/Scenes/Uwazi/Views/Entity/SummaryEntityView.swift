//
//  SubmitEntityView.swift
//  Tella
//
//  Created by Gustavo on 06/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
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
        ContainerView {
            VStack {
                templateData
                
                UwaziDividerWidget()
                
                Spacer()
                    .frame(height: 20)
                
                entityTitle
                
                entityContent
                
                Spacer()
                
                if summaryViewModel.shouldHideBottomActionView {
                    UwaziDividerWidget()
                    bottomActionView
                }
            }
            
            if summaryViewModel.isLoading {
                CircularActivityIndicatory()
            }

        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(LocalizableUwazi.uwaziEntitySummaryDetailToolbarItem.localized)
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading) // Align to leading
                }
            }
        }
        .onReceive(summaryViewModel.$shouldHideView, perform: { shouldHideView in
            if shouldHideView {
                dismissViews()
            }
        })

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

    var entityContent: some View {
        VStack {
            entityResponseItem
            UwaziFileItems(files: summaryViewModel.getUwaziVaultFiles())
        }           .padding(.horizontal, 16)

    }
    
    var bottomActionView: some View {
        HStack {
            
            
            TellaButtonView<AnyView> (title: "SUBMIT LATER",
                                      nextButtonAction: .action,
                                      buttonType: .clear,
                                      isValid: .constant(true)) {
                
                
                summaryViewModel.submitLater()
            }
            
            Spacer()
            
            TellaButtonView<AnyView> (title: "SUBMIT",
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: .constant(true)) {
                
                summaryViewModel.submitEntity() 
                
            }
            
        }.padding(.horizontal)
    }
    
    var entityResponseItem: some View {

        VaultFileItemView(file: VaultFileItem(image: AnyView(Image("document")),
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
                VaultFileItemView(file: VaultFileItem(image: file.listImage,
                                                      name: file.name,
                                                      size: file.size.getFormattedFileSize(),
                                                      iconName: file.statusIcon))
                .padding(.bottom, 17)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
