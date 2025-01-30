//
//  ServerCreateFolderView.swift
//  Tella
//
//  Created by RIMA on 5/7/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
struct ServerCreateFolderView: View {
    
    @State var isValid : Bool = false
    @StateObject var createFolderViewModel: ServerCreateFolderViewModel
    
    var navigateToSuccessLogin: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                headerView
                textField
                Spacer()
                bottomView
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))

            VStack {
                Spacer()
                if case .error(let message) = createFolderViewModel.createFolderState, !message.isEmpty {
                    ToastView(message: message)
                }
            }
            if  createFolderViewModel.createFolderState == .loading {
                CircularActivityIndicatory()
            }
        }
        .containerStyle()
        .navigationBarHidden(true)
        .onReceive(createFolderViewModel.$createFolderState) { value in
            if value == .loaded(true) {
                navigateToSuccessLogin?()
            }
        }
    }
    
    var textField: some View {
        TextfieldView(fieldContent: $createFolderViewModel.folderName,
                      isValid: $isValid,
                      shouldShowError: $createFolderViewModel.shouldShowError,
                      errorMessage: createFolderViewModel.errorMessage,
                      validationErrorMessage: LocalizableSettings.settCreateFolderError.localized,
                      fieldType: .folderName,
                      placeholder: LocalizableSettings.settCreateFolderPlaceholder.localized,
                      shouldValidateOnChange:true)

        .padding(.vertical, 12)
    }
    
    var headerView: some View {
        ServerConnectionHeaderView(
            title: LocalizableSettings.settCreateFolderTitle.localized,
            subtitle: createFolderViewModel.headerViewSubtitleText,
            imageIconName: createFolderViewModel.imageIconName
        )
    }
    
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: $isValid,
                                nextButtonAction: .action,
                                shouldHideNext: createFolderViewModel.createFolderState == .loading,
                                shouldHideBack: false,
                                nextAction: {
            self.createFolderViewModel.createFolderAction?()
        })
    }
}
struct ServerCreateFolderView_Previews: PreviewProvider {
    static var previews: some View {
        ServerCreateFolderView(createFolderViewModel: ServerCreateFolderViewModel(headerViewSubtitleText: "Connection", imageIconName: "nextcloud.icon"))
    }
}
