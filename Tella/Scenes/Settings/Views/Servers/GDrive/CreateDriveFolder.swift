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
    @EnvironmentObject var gDriveServerViewModel: GDriveServerViewModel
    var body: some View {
        ContainerView {
            VStack(spacing: 20) {
                Spacer()
                ServerConnectionHeaderView(
                    title: LocalizableSettings.GDriveCreatePersonalFolderTitle.localized,
                    subtitle: LocalizableSettings.GDriveCreatePersonalFolderDesc.localized
                )
                TextfieldView(fieldContent: $fieldContent,
                              isValid: $isValid,
                              shouldShowError: .constant(false),
                              fieldType: .text,
                              placeholder: LocalizableSettings.GDriveCreatePersonalFolderPlaceholder.localized)
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
            gDriveServerViewModel.createDriveFolder(folderName: fieldContent) {
                navigateTo(destination: SuccessLoginView(navigateToAction: {self.popToRoot()}, type: .gDrive))
            }
        })

    }
}

#Preview {
    CreateDriveFolder()
}
