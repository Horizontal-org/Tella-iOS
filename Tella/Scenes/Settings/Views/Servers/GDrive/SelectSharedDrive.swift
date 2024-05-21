//
//  SelectSharedDrive.swift
//  Tella
//
//  Created by gus valbuena on 5/20/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SelectSharedDrive: View {
    var body: some View {
        ContainerView {
            VStack(alignment: .leading){
                HStack {
                    Text("one of the drive")
                        .font(.custom(Styles.Fonts.regularFontName, size: 15))
                        .foregroundColor(.white)
                    Spacer()
                    Image("settings.done")
                }.padding(18)

                Spacer()
            }.background(Color.white.opacity(0.05))
            .toolbar {
                LeadingTitleToolbar(title: "Select shared drive")
            }
        }
    }
}

#Preview {
    SelectSharedDrive()
}
