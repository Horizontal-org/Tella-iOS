//
//  UwaziFileSelector.swift
//  Tella
//
//  Created by Gustavo on 24/10/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziFileSelector: View {
    @EnvironmentObject var prompt: UwaziEntryPrompt
    var body: some View {
        VStack {
            Spacer()
            Text(prompt.helpText!)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                
            } label: {
                SelectFileComponent(title: "Select files")
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            .padding(.bottom, 12)
        }
    }
}

struct SelectFileComponent: View {
    let title: String

    var body: some View {
        HStack {
            Image("uwazi.add-files")
                .padding()
            Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct UwaziFileSelector_Previews: PreviewProvider {
    static var previews: some View {
        UwaziFileSelector()
    }
}
