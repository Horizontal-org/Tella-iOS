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
    @State var selectedDrive: String = ""
    @EnvironmentObject var gDriveServerViewModel: GDriveServerViewModel
    var body: some View {
        ContainerView {
            VStack(alignment: .leading){
                selectSharedDriveHeader
                VStack(alignment: .leading) {
                    ForEach(gDriveServerViewModel.sharedDrives, id: \.id) { drive in
                        DriveCardView(sharedDrive: drive, selectedDrive: $selectedDrive)
                    }

                    Spacer()
                }
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.03))
            }
            .navigationBarHidden(true)

        }
    }
    
    var selectSharedDriveHeader: some View {
        NavigationHeaderView(backButtonAction:{ backButtonAction() },
                             title: "Select shared drive",
                             type: .save)
    }
    
    func backButtonAction() -> Void {
        gDriveServerViewModel.addServer(rootFolder: selectedDrive) {
            navigateTo(destination: SuccessLoginView(navigateToAction: {self.popToRoot()}, type: .gDrive))
        }
    }
}

struct DriveCardView: View {
    var sharedDrive: SharedDrive
    @Binding var selectedDrive: String
    var body: some View {
        Button(action: {
            self.selectedDrive = sharedDrive.id
        }) {
            HStack {
                Text(sharedDrive.name)
                    .font(.custom(Styles.Fonts.regularFontName, size: 16))
                    .foregroundColor(.white)
                Spacer()
                if selectedDrive == sharedDrive.id {
                    Image("settings.done")
                }
            }
            .padding(18)
            .background(selectedDrive == sharedDrive.id ? Color.white.opacity(0.1) : Color.clear)
        }
    }
}


#Preview {
    SelectSharedDrive()
}
