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
    var body: some View {
        ContainerView {
            VStack(spacing: 20) {
                Spacer()
                headerView
                connectionsButtons
                Spacer()
                bottomView
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            .toolbar {
                LeadingTitleToolbar(title: "Select Google drive")
            }
        }
    }
    
    var headerView: some View {
        VStack(spacing: 20) {
            Image("gdrive.icon")
            Text("Select a Drive to connect to")
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            Text("You can either connect to an organizational Shared Drive or create a new folder in your personal Drive.")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
    
    var connectionsButtons: some View {
        VStack {
            TellaButtonView<AnyView>(
                title: "USE SHARED DRIVE",
                nextButtonAction: .action,
                isOverlay: selectedDriveConnectionType == .shared,
                isValid: .constant(true),
                action: { selectedDriveConnectionType = .shared }
            ).padding(.vertical, 5)
            TellaButtonView<AnyView>(
                title: "USE PERSONAL DRIVE",
                nextButtonAction: .action,
                isOverlay: selectedDriveConnectionType == .personal,
                isValid: .constant(true),
                action: {selectedDriveConnectionType = .personal}
            ).padding(.vertical, 5)
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
                navigateTo(destination: SelectSharedDrive())
            case .personal:
                dump("personal")
            default:
                break
            }
        })

    }
}

#Preview {
    SelectDriveConnection(selectedDriveConnectionType: .personal)
}
