//
//  SelectSharedDrive.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import GoogleAPIClientForREST

struct SelectSharedDrive: View {
    @EnvironmentObject var gDriveServerViewModel: GDriveServerViewModel
    var body: some View {
        ContainerView {
            VStack(alignment: .leading){
                selectSharedDriveHeader
                sharedDriveList
            }
            .navigationBarHidden(true)

        }
    }
    
    var sharedDriveList: some View {
        VStack(alignment: .leading) {
            ForEach(gDriveServerViewModel.sharedDrives, id: \.id) { drive in
                DriveCardView(sharedDrive: drive,
                              isSelected: drive.id == gDriveServerViewModel.selectedDrive?.id
                )
            }

            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.03))
    }
    
    var selectSharedDriveHeader: some View {
        NavigationHeaderView(backButtonAction:{ backButtonAction() },
                             title: LocalizableSettings.GDriveSelectSharedDriveToolbar.localized,
                             type: .save)
    }
    
    func backButtonAction() -> Void {
        gDriveServerViewModel.addServer(rootFolder: gDriveServerViewModel.selectedDrive?.id ?? "") {
            navigateTo(destination: SuccessLoginView(navigateToAction: {self.popToRoot()}, type: .gDrive))
        }
    }
}

struct DriveCardView: View {
    var sharedDrive: SharedDrive
    var isSelected: Bool
    @EnvironmentObject var gDriveServerViewModel: GDriveServerViewModel
    var body: some View {
        Button(action: {
            gDriveServerViewModel.selectedDrive = sharedDrive
        }) {
            HStack {
                Text(sharedDrive.name)
                    .font(.custom(Styles.Fonts.regularFontName, size: 16))
                    .foregroundColor(.white)
                Spacer()
                if isSelected {
                    Image("settings.done")
                }
            }
            .padding(18)
            .background(isSelected ? Color.white.opacity(0.1) : Color.clear)
        }
    }
}


#Preview {
    SelectSharedDrive()
}
