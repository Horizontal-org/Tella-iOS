//
//  UwaziEntitySelectorView.swift
//  Tella
//
//  Created by gus valbuena on 3/25/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct EntitySelectorView: View {
    @State var selectedEntities: [EntityRelationshipItem] = []
    var body: some View {
        ContainerView {
            VStack {
                SearchBarView()
                Text("Search for or select the entities you want to connect to this property.")
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white.opacity(0.87))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                ForEach(MockDataProvider.values) {entity in
                    entityListOptionsView(entity: entity, selectedEntities: $selectedEntities, isSelected: isSelected(entity: entity))
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("incident")
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    func isSelected(entity: EntityRelationshipItem) -> Bool {
        if selectedEntities.contains(where: { $0.id == entity.id}) { return true }
        
        return false
    }
}

struct entityListOptionsView: View {
    var entity: EntityRelationshipItem
    @Binding var selectedEntities: [EntityRelationshipItem]
    var isSelected: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                if isSelected {
                    selectedEntities.removeAll { $0.id == entity.id }
                } else {
                    selectedEntities.append(entity)
                }
            }, label: {
                entityOptionView
            })
        }
        .background(isSelected ? Color.white.opacity(0.08) : Styles.Colors.backgroundMain)
    }
    
    var entityOptionView: some View {
        HStack(spacing: 15) {
            if isSelected {
                Image("files.selected")
            } else {
                Image("files.unselected")
            }
            Text(entity.label)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    EntitySelectorView()
}
