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
    @State var sharedDrives: [SharedDrive] = []
    var body: some View {
        ContainerView {
            VStack(alignment: .leading){
                ForEach(sharedDrives, id: \.id) { drive in
                    DriveCardView(sharedDrive: drive, selectedDrive: $selectedDrive)
                }

                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.03))
            .toolbar {
                LeadingTitleToolbar(title: "Select shared drive")
                // remove this after merging with uwazi relationships
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        navigateTo(destination: SuccessLoginView(navigateToAction: {}, type: .gDrive))
                    }) {
                        Image("report.select-files")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                }
            }
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
