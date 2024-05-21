//
//  SelectSharedDrive.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SelectSharedDrive: View {
    @State var selectedDrive: String = ""
    var body: some View {
        ContainerView {
            VStack(alignment: .leading){
                ForEach(SharedDrivesList, id: \.id) { drive in
                    DriveCardView(sharedDrive: drive, selectedDrive: $selectedDrive)
                }

                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.03))
            .toolbar {
                LeadingTitleToolbar(title: "Select shared drive")
            }
        }
    }
}

struct DriveCardView: View {
    var sharedDrive: SharedDrive
    @Binding var selectedDrive: String
    var body: some View {
        Button(action: {
            self.selectedDrive = sharedDrive.name
        }) {
            HStack {
                Text(sharedDrive.name)
                    .font(.custom(Styles.Fonts.regularFontName, size: 16))
                    .foregroundColor(.white)
                Spacer()
                if selectedDrive == sharedDrive.name {
                    Image("settings.done")
                }
            }
            .padding(18)
            .background(selectedDrive == sharedDrive.name ? Color.white.opacity(0.1) : Color.clear)
        }
    }
}

#Preview {
    SelectSharedDrive()
}
