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
    var body: some View {
        ContainerView {
            VStack(spacing: 20) {
                Spacer()
                headerView
                TextfieldView(fieldContent: $fieldContent, isValid: .constant(true), shouldShowError: .constant(false), fieldType: .text, placeholder: "Folder name")
                    .padding(.vertical, 12)
                Spacer()
                bottomView
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            .navigationBarHidden(true)
        }
    }
    
    var headerView: some View {
        VStack(spacing: 20) {
            Image("gdrive.icon")
            Text("Create new folder")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("Your reports will be uploaded to a new folder on your Google Drive. Choose a name for this folder here.")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }.padding(.horizontal, 20)
    }
    
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: .constant(true),
                                nextButtonAction: .action,
                                shouldHideNext: false,
                                shouldHideBack: false,
                                nextAction: {})

    }
}

#Preview {
    CreateDriveFolder()
}
