//
//  UwaziRelationshipWidget.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziRelationshipWidget: View {
    @ObservedObject var prompt: UwaziRelationshipEntryPrompt
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    var body: some View {
        VStack {
            Text(LocalizableUwazi.uwaziEntityRelationshipExpl.localized)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                navigateTo(destination: EntitySelectorView(selectedValues: $prompt.value)
                    .environmentObject(entityViewModel)
                    .environmentObject(prompt)
                )
            } label: {
                entitiesSelect
            }
            .background(Color.white.opacity(0.08))
            .cornerRadius(15)
            
            if(!prompt.value.isEmpty) {
                selectedEntities
            }
        }
        .onChange(of: prompt.value) { newValue in
            entityViewModel.publishUpdates()
        }
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
    
    var selectedEntities: some View {
        VStack {
            Text("\(prompt.value.count) \(prompt.value.count == 1 ? LocalizableUwazi.uwaziEntityRelationshipSingleConnection.localized : LocalizableUwazi.uwaziEntityRelationshipMultipleConnections.localized)"
                )
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack {
                ForEach(prompt.value, id: \.self) {entity in
                    HStack{
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 35, height: 38, alignment: .center)
                            .overlay(
                                Image("files.list")
                            )
                        Text(getEntityLabel(value: entity))
                            .font(.custom(Styles.Fonts.regularFontName, size: 14))
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                            .padding(.horizontal, 4)
                    }
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    func getEntityLabel (value: String) -> String {
        return entityViewModel.relationshipEntities.flatMap{ $0.values }
            .first(where: { $0.id == value })?.label ?? ""
    }
}
