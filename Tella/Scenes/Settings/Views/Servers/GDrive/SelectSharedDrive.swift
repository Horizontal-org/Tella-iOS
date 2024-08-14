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
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        ContainerView {
            VStack(alignment: .leading){
                selectSharedDriveHeader
                sharedDriveContent
            }
            .navigationBarHidden(true)

        }
        .onAppear {
            gDriveServerViewModel.getSharedDrives()
        }
    }
    
    var sharedDriveContent: some View {
        VStack(alignment: .leading) {
            switch gDriveServerViewModel.sharedDriveState {
            case .loading:
                CircularActivityIndicatory()
            case .loaded(let drives):
                sharedDriveList(drives: drives)
            case .error(let message):
                ToastView(message: message)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.03))
    }
    
    @ViewBuilder
    func sharedDriveList(drives: [SharedDrive]) -> some View {
        ForEach(drives, id: \.id) {drive in
            DriveCardView(sharedDrive: drive,
                          isSelected: drive.id == gDriveServerViewModel.selectedDrive?.id
            )
        }
    }
    
    
    var selectSharedDriveHeader: some View {
        NavigationHeaderView(backButtonAction:{ backButtonAction() },
                             title: LocalizableSettings.gDriveSelectSharedDriveToolbar.localized,
                             type: .save)
    }
    
    func backButtonAction() -> Void {
        guard let selectedDrive = gDriveServerViewModel.selectedDrive else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        gDriveServerViewModel.addServer(rootFolder: selectedDrive.id) {
            navigateTo(destination: SuccessLoginView(
                navigateToAction: {navigateTo(destination: reportsView)},
                type: .gDrive)
            )
        }
    }
    
    private var reportsView: some View {
        ReportMainView(reportMainViewModel: GDriveViewModel(mainAppModel: gDriveServerViewModel.mainAppModel), diContainer: GDriveDIContainer())
    }
}

struct DriveCardView: View {
    var sharedDrive: SharedDrive
    var isSelected: Bool
    @EnvironmentObject var gDriveServerViewModel: GDriveServerViewModel
    var body: some View {
        Button(action: {
            gDriveServerViewModel.handleSelectedDrive(drive: sharedDrive)
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
