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
            FileItems(files: summaryViewModel.entityInstance?.documents ?? [])
            FileItems(files: summaryViewModel.entityInstance?.attachments ?? [])
        }
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
        HStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.2))
                .frame(width: 48, height: 48, alignment: .center)
                .overlay(
                    ZStack{
                        Image("document")
                    }
                        .frame(width: 48, height: 48)
                        .cornerRadius(5)
                )
            VStack(alignment: .leading) {
                Text(LocalizableUwazi.uwaziEntitySummaryDetailEntityResponseTitle.localized)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                
                Spacer()
                    .frame(height: 2)
                
                Text(summaryViewModel.getEntityResponseSize())
                    .font(.custom(Styles.Fonts.regularFontName, size: 10))
                    .foregroundColor(Color.white)
            }
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 17)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func dismissViews() {
        self.popTo(ViewClassType.uwaziView)
    }
}

