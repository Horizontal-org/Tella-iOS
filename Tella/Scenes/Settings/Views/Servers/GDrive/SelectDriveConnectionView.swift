//
//  SelectDriveConnection.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SelectDriveConnectionView: View {
    @State var selectedDriveConnectionType: DriveConnectionType = .none
    @ObservedObject var gDriveServerViewModel: GDriveServerViewModel
    
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
    ContainerViewWithHeader {
        navigationBar
    } content: {
        contentView
    }

    var navigationBar: some View {
        NavigationHeaderView(title: LocalizableSettings.gDriveSelectTypeToolbar.localized ,trailingButton: .none)
    }
    
    var contentView: some View {
        VStack(spacing: 24) {
            Spacer()
            headerView
            connectionsButtons
            Spacer()
            bottomView
        }
        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
    }
    
    var headerView: some View {
        ServerConnectionHeaderView(
            title: LocalizableSettings.gDriveSelectTypeTitle.localized,
            subtitle: LocalizableSettings.gDriveSelectTypeDesc.localized,
            imageIconName: "gdrive.icon"
        )
    }
    
    var connectionsButtons: some View {
        VStack(spacing: 14) {
            TellaButtonView<AnyView>(
                title: LocalizableSettings.gDriveSelectTypeShared.localized,
                nextButtonAction: .action,
                isOverlay: selectedDriveConnectionType == .shared,
                isValid: $gDriveServerViewModel.isSharedDriveButtonValid,
                action: { selectedDriveConnectionType = .shared }
            )
            TellaButtonView<AnyView>(
                title: LocalizableSettings.gDriveSelectTypePersonal.localized,
                nextButtonAction: .action,
                isOverlay: selectedDriveConnectionType == .personal,
                isValid: .constant(true),
                action: {selectedDriveConnectionType = .personal}
            )
            moreInfoText
        }
    }

    var moreInfoText: some View {
        Link(destination: URL(string: TellaUrls.gDriveURL)!) {
            Text(LocalizableSettings.gDriveSelectTypeMoreInfo.localized)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Styles.Colors.yellow)
                .multilineTextAlignment(.center)
                .padding(.vertical, 5)
        }
    }
    
    var bottomView: some View {
        BottomLockView<AnyView>(isValid: .constant(true),
                                nextButtonAction: .action,
                                shouldHideNext: selectedDriveConnectionType == .none,
                                shouldHideBack: false,
                                nextAction: {
            switch selectedDriveConnectionType {
            case .shared:
                navigateTo(
                    destination: SelectSharedDriveView(gDriveServerViewModel: gDriveServerViewModel)
                )
            case .personal:
                navigateTo(
                    destination: CreateDriveFolderView(gDriveServerViewModel: gDriveServerViewModel))
            default:
                break
            }
        })
    }
}

#Preview {
    SelectDriveConnectionView(selectedDriveConnectionType: .personal, gDriveServerViewModel: GDriveServerViewModel(repository: GDriveRepository(),mainAppModel: MainAppModel.stub()))
}
