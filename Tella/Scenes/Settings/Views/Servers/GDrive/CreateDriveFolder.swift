//
//  CreateDriveFolder.swift
//  Tella
//
//  Created by gus valbuena on 5/21/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CreateDriveFolder: View {
    @State var fieldContent : String = ""
    @State var isValid : Bool = false
    var body: some View {
        ContainerView {
            VStack(spacing: 20) {
                Spacer()
                ServerConnectionHeaderView(
                    title: "Create new folder",
                    subtitle: "Your reports will be uploaded to a new folder on your Google Drive. Choose a name for this folder here."
                )
                TextfieldView(fieldContent: $fieldContent,
                              isValid: .constant(true),
                              shouldShowError: .constant(false),
                              fieldType: .text,
                              placeholder: "Folder name")
                    .padding(.vertical, 12)
                    .onChange(of: fieldContent) { newValue in
                        isValid = !newValue.isEmpty
                    }
                Spacer()
                bottomView
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            .navigationBarHidden(true)
        }
    }
    
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: $isValid,
                                nextButtonAction: .action,
                                shouldHideNext: false,
                                shouldHideBack: false,
                                nextAction: {
            navigateTo(destination: SuccessLoginView(navigateToAction: {}, type: .gDrive))
        })

    }
}

#Preview {
    CreateDriveFolder()
}
