//
//  SubmittedEntityView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 9/5/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SubmittedEntityView: View {
    
    @StateObject var submittedEntityViewModel : SubmittedEntityViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var sheetManager: SheetManager

    init(mainAppModel: MainAppModel,
         entityInstance: UwaziEntityInstance? = nil,
         entityInstanceId: Int? = nil) {
        _submittedEntityViewModel = StateObject(wrappedValue: SubmittedEntityViewModel(mainAppModel: mainAppModel,
                                                                                       entityInstance: entityInstance,
                                                                                       entityInstanceId:entityInstanceId))
    }
    var body: some View {
        ContainerView {
            VStack(spacing: 20) {
                templateData
                
                entityContent
                
                Spacer()
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            LeadingTitleToolbar(title: LocalizableUwazi.submitted_AppBar.localized)
            TrailingImageButtonToolBar(imageName: "report.delete-outbox", completion: {showDeleteConfirmationView()})
        }      
        .onReceive(submittedEntityViewModel.$shouldShowToast) { shouldShowToast in
            if shouldShowToast {
                Toast.displayToast(message: submittedEntityViewModel.toastMessage)
                self.popTo(ViewClassType.uwaziView)
            }
        }
    }
    
    var templateData: some View {
        
        HStack(spacing: 20) {
            
            Image("report.submitted")
            
            VStack(spacing: 6) {
                
                Text(submittedEntityViewModel.templateName)
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(submittedEntityViewModel.uploadedOn)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(submittedEntityViewModel.filesDetails)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
        }.padding(16)
    }
    
    var entityContent: some View {
        VStack {
            entityResponseItem
            UwaziFileItems(files: submittedEntityViewModel.uwaziVaultFiles)
        }.padding(.horizontal, 20)
        
    }
    
    
    var entityResponseItem: some View {
        
        VaultFileItemView(file: VaultFileItemViewModel(image: AnyView(Image("document")),
                                              name: LocalizableUwazi.uwaziEntitySummaryDetailEntityResponseTitle.localized,
                                              size: submittedEntityViewModel.getEntityResponseSize(),
                                              iconName: "report.submitted"))
        .padding(.bottom, 17)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func showDeleteConfirmationView() {
       let deleteTitle = LocalizableUwazi.submittedDeleteSheetTitle.localized
        let deleteMessage = LocalizableUwazi.submittedDeleteSheetExpl.localized
        let cancelText = LocalizableUwazi.submittedDeleteCancelAction.localized
        let actionText = LocalizableUwazi.submittedDeleteDeleteAction.localized

        sheetManager.showBottomSheet(modalHeight: 200) {
            return ConfirmBottomSheet(titleText: deleteTitle,
                                      msgText: deleteMessage,
                                      cancelText: cancelText,
                                      actionText: actionText) {
                submittedEntityViewModel.deleteEntityInstance()
            }
        }
    }
    private func dismissViews() {
        self.popTo(ViewClassType.uwaziView)
    }
}

#Preview {
    SubmittedEntityView(mainAppModel: MainAppModel.stub())
}



