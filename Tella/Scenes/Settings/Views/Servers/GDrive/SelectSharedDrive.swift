//
//  SelectSharedDrive.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import GoogleAPIClientForREST

struct SelectSharedDriveView: View {
    @StateObject var gDriveServerViewModel: GDriveServerViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBar
        } content: {
            contentView
        }
        
        .onAppear {
            gDriveServerViewModel.getSharedDrives()
        }
    }
    
    var navigationBar: some View {
        NavigationHeaderView(title: LocalizableSettings.gDriveSelectSharedDriveToolbar.localized,
                             backButtonAction:{ backButtonAction() },
                             trailingButton: .save)
    }
    
    var contentView: some View {
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
                          isSelected: drive.id == gDriveServerViewModel.selectedDrive?.id,
                          gDriveServerViewModel: gDriveServerViewModel
            )
        }
    }
    
    
    
    func backButtonAction() {
        guard let selectedDrive = gDriveServerViewModel.selectedDrive else {
            presentationMode.wrappedValue.dismiss()
            return
        }
        gDriveServerViewModel.addServer(rootFolder: selectedDrive.id,
                                        rootFolderName: selectedDrive.name)
        
        navigateTo(destination: SuccessLoginView(navigateToAction: {navigateTo(destination: reportsView)},
                                                 type: .gDrive))
        
    }
    
    private var reportsView: GdriveReportMainView {
        GdriveReportMainView(reportsMainViewModel: GDriveViewModel(mainAppModel: gDriveServerViewModel.mainAppModel, gDriveRepository: GDriveRepository()))
    }
}

struct DriveCardView: View {
    var sharedDrive: SharedDrive
    var isSelected: Bool
    @StateObject var gDriveServerViewModel: GDriveServerViewModel
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
    SelectSharedDriveView(gDriveServerViewModel: GDriveServerViewModel(repository: GDriveRepository(), mainAppModel: MainAppModel.stub()))
}
