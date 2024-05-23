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
    @State var sharedDrives: [GTLRDrive_Drive] = []
    var body: some View {
        ContainerView {
            VStack(alignment: .leading){
                ForEach(sharedDrives, id: \.identifier) { drive in
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
    var sharedDrive: GTLRDrive_Drive
    @Binding var selectedDrive: String
    var body: some View {
        Button(action: {
            self.selectedDrive = sharedDrive.identifier ?? ""
        }) {
            HStack {
                Text(sharedDrive.name ?? "")
                    .font(.custom(Styles.Fonts.regularFontName, size: 16))
                    .foregroundColor(.white)
                Spacer()
                if selectedDrive == sharedDrive.identifier {
                    Image("settings.done")
                }
            }
            .padding(18)
            .background(selectedDrive == sharedDrive.identifier ? Color.white.opacity(0.1) : Color.clear)
        }
    }
}


#Preview {
    SelectSharedDrive()
}
