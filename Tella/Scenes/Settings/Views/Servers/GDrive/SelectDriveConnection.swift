//
//  SelectDriveConnection.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
enum DriveConnectionType {
    case shared
    case personal
    case none
}
struct SelectDriveConnection: View {
    @State var selectedDriveConnectionType: DriveConnectionType = .none
    @ObservedObject var gDriveServerViewModel: GDriveServerViewModel
    var body: some View {
        ContainerView {
            VStack(spacing: 24) {
                Spacer()
                ServerConnectionHeaderView(
                    title: "Select a Drive to connect to",
                    subtitle: "You can either connect to an organizational Shared Drive or create a new folder in your personal Drive."
                )
                connectionsButtons
                Spacer()
                bottomView
            }.padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            .toolbar {
                LeadingTitleToolbar(title: "Select Google drive")
            }
        }
    }
    
    var connectionsButtons: some View {
        VStack(spacing: 14) {
            TellaButtonView<AnyView>(
                title: "USE SHARED DRIVE",
                nextButtonAction: .action,
                isOverlay: selectedDriveConnectionType == .shared,
                isValid: .constant(true),
                action: { selectedDriveConnectionType = .shared }
            )
            TellaButtonView<AnyView>(
                title: "USE PERSONAL DRIVE",
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
            Text("Learn more about the types of drives")
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
                    destination: SelectSharedDrive()
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
    SelectDriveConnection(selectedDriveConnectionType: .personal, gDriveServerViewModel: GDriveServerViewModel(mainAppModel: MainAppModel.stub()))
}
