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
            VStack {
                Spacer()
                if case .error(let message) = createFolderViewModel.createFolderState {
                    ToastView(message: message)
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
        .navigationBarHidden(true)
        .containerStyle()
        .onReceive(createFolderViewModel.$createFolderState) { value in
            if value == .loaded(true) {
                navigateToSuccessLogin?()
            }
        }
    }
    
    var textField: some View {
        TextfieldView(fieldContent: $createFolderViewModel.fieldContent,
                      isValid: $isValid,
                      shouldShowError: .constant(false),
                      fieldType: .text,
                      placeholder: createFolderViewModel.textFieldPlaceholderText)
        .padding(.vertical, 12)
        .onChange(of: createFolderViewModel.fieldContent) { newValue in
            isValid = !newValue.isEmpty
        }
    }
    
    var headerView: some View {
        ServerConnectionHeaderView(
            title: createFolderViewModel.headerViewTitleText,
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
