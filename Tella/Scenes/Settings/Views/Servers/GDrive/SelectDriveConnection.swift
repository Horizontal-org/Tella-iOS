//
//  SelectDriveConnection.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SelectDriveConnection: View {
    @State var selectedDriveConnectionType: DriveConnectionType = .none
    @ObservedObject var gDriveServerViewModel: GDriveServerViewModel
    var body: some View {
        ContainerView {
            VStack {
                selectDriveToolbar
                VStack(spacing: 24) {
                    Spacer()
                    headerView
                    connectionsButtons
                    Spacer()
                    bottomView
                }
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            }
            .navigationBarHidden(true)
        }
    }
    
    var selectDriveToolbar: some View {
        NavigationHeaderView(title: LocalizableSettings.gDriveSelectTypeToolbar.localized ,type: .none)
    }
    
    var headerView: some View {
        ServerConnectionHeaderView(
            title: LocalizableSettings.gDriveSelectTypeTitle.localized,
            subtitle: LocalizableSettings.gDriveSelectTypeDesc.localized
        )
    }
    
    var connectionsButtons: some View {
        VStack(spacing: 14) {
            TellaButtonView<AnyView>(
                title: LocalizableSettings.gDriveSelectTypeShared.localized,
                nextButtonAction: .action,
                isOverlay: selectedDriveConnectionType == .shared,
                isValid: .constant(true),
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
                    destination: SelectSharedDriveView()
                        .environmentObject(gDriveServerViewModel)
                )
            case .personal:
                navigateTo(
                    destination: CreateDriveFolder()
                        .environmentObject(gDriveServerViewModel))
            default:
                break
            }
        })

    }
}

#Preview {
    SelectDriveConnection(selectedDriveConnectionType: .personal, gDriveServerViewModel: GDriveServerViewModel(repository: GDriveRepository(),mainAppModel: MainAppModel.stub()))
}
