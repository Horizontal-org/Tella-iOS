//
//  SelectedEntityView.swift
//  Tella
//
//  Created by gus valbuena on 5/13/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SelectedEntityView : View {
    
    @ObservedObject var prompt: UwaziRelationshipEntryPrompt
    
    var body: some View {
        VStack {
            entitiesCounter
            selectedEntitiesList
        }
    }
    
    var entitiesCounter: some View {
        Text("\(prompt.value.count) \(prompt.value.count == 1 ? LocalizableUwazi.uwaziEntityRelationshipSingleConnection.localized : LocalizableUwazi.uwaziEntityRelationshipMultipleConnections.localized)"
        )
        .font(.custom(Styles.Fonts.regularFontName, size: 14))
        .foregroundColor(Color.white.opacity(0.87))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var selectedEntitiesList: some View {
        VStack {
            ForEach(prompt.value, id: \.self) {entity in
                entityView(for: entity)
            }
        }
    }
    
    private func entityView(for entity: String) -> some View {
        HStack {
            entityIcon
            entityLabel(for: entity)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var entityIcon: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.white.opacity(0.2))
            .frame(width: 35, height: 38, alignment: .center)
            .overlay(
                Image("files.list")
            )
    }
    
    private func entityLabel(for value: String) -> some View {
        Text(getEntityLabel(value: value))
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(Color.white)
            .lineLimit(1)
            .padding(.horizontal, 4)
    }
    
    func getEntityLabel (value: String) -> String {
        return prompt.selectValues?
            .first(where: { $0.id == value })?.label ?? ""
    }
}
