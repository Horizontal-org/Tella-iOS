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
                headerView
                textField
                Spacer()
                bottomView
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            .navigationBarHidden(true)
        }.onReceive(gDriveServerViewModel.$createFolderState) {createFolderState in
            if case .error(let message) = createFolderState {
                Toast.displayToast(message: message)
            }
        }
    }
    
    var headerView: some View {
        ServerConnectionHeaderView(
            title: LocalizableSettings.GDriveCreatePersonalFolderTitle.localized,
            subtitle: LocalizableSettings.GDriveCreatePersonalFolderDesc.localized
        )
    }
    
    var textField: some View {
        TextfieldView(fieldContent: $fieldContent,
                      isValid: $isValid,
                      shouldShowError: .constant(false),
                      fieldType: .text,
                      placeholder: LocalizableSettings.GDriveCreatePersonalFolderPlaceholder.localized)
            .padding(.vertical, 12)
            .onChange(of: fieldContent) { newValue in
                isValid = !newValue.isEmpty
            }
    }
    
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: $isValid,
                                nextButtonAction: .action,
                                shouldHideNext: gDriveServerViewModel.createFolderState == .loading,
                                shouldHideBack: false,
                                nextAction: {
            gDriveServerViewModel.createDriveFolder(folderName: fieldContent) {
                navigateTo(destination: SuccessLoginView(
                    navigateToAction: {navigateTo(destination: reportsView)},
                    type: .gDrive)
                )
            }
        })

    }
    
    private var reportsView: some View {
        ReportMainView(reportMainViewModel: GDriveViewModel(mainAppModel: gDriveServerViewModel.mainAppModel), diContainer: GDriveDIContainer())
    }
}

#Preview {
    CreateDriveFolder()
}
