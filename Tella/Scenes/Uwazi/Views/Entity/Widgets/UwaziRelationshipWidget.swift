//
//  UwaziRelationshipWidget.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziRelationshipWidget: View {
    @EnvironmentObject var prompt: UwaziEntryPrompt
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    var body: some View {
        VStack {
            Text("Select the entities you want to connect to this property.")
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                navigateTo(destination: EntitySelectorView()
                    .environmentObject(entityViewModel)
                    .environmentObject(prompt)
                )
            } label: {
                entitiesSelect
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(15)

        }
    }


    var entitiesSelect: some View {
        HStack {
            Image("uwazi.add-files")
                .padding(.vertical, 20)
            Text("Select entities")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal, 16)
    }
}
#Preview {
    UwaziRelationshipWidget()
}
