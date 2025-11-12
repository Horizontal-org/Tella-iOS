//
//  UwaziRelationshipWidget.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziRelationshipWidget: View {
    @ObservedObject var prompt: UwaziRelationshipEntryPrompt
    var entityViewModel: UwaziEntityViewModel
    
    var body: some View {
        VStack {
            Text(LocalizableUwazi.uwaziEntityRelationshipExpl.localized)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            selectEntitiesButton
            if(!prompt.value.isEmpty) {
                SelectedEntityView(prompt: prompt)
            }
        }
        .onChange(of: prompt.value) { newValue in
            entityViewModel.publishUpdates()
        }
    }

    var selectEntitiesButton : some View {
        Button {
            navigateTo(destination: EntitySelectorView(prompt: prompt)
            )
        } label: {
            entitiesSelect
        }
        .background(Color.white.opacity(0.08))
        .cornerRadius(15)
    }

    var entitiesSelect: some View {
        HStack {
            Image("uwazi.add-files")
                .padding(.vertical, 20)
            Text(prompt.value.isEmpty ?
                    LocalizableUwazi.uwaziEntityRelationshipSelectTitle.localized :
                    LocalizableUwazi.uwaziEntityRelationshipAddMoreTitle.localized)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal, 16)
    }
}
