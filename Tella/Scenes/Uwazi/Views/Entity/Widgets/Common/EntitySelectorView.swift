//
//  EntitySelectorView.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct EntitySelectorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var prompt: UwaziRelationshipEntryPrompt
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
    @Binding var selectedValues: [EntityRelationshipItem]
    @State private var searchText: String = ""
    var body: some View {
        ContainerView {
            VStack {
                NavigationHeaderView(backButtonAction: {presentationMode.wrappedValue.dismiss()},
                                     reloadAction: {presentationMode.wrappedValue.dismiss()},
                                     title: "incident",
                                     type: .save,
                                     showRightButton: !selectedValues.isEmpty
                ).padding(.horizontal, 18)
                
                SearchBarView(searchText: $searchText)
                Text(LocalizableUwazi.uwaziRelationshipListExpl.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white.opacity(0.87))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                ScrollView {
                    ForEach(filteredEntities()) {entity in
                        entityListOptionsView(entity: entity,
                                              value: $prompt.value,
                                              isSelected: isSelected(entity: entity)
                        )
                    }
                }
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }

    func isSelected(entity: EntityRelationshipItem) -> Bool {
        if prompt.value.contains(where: { $0.id == entity.id}) { return true }

        return false
    }
    
    func filteredEntities() -> [EntityRelationshipItem] {
        return entityViewModel.relationshipEntities
            .first { $0.id == prompt.content }?
            .values
            .filter { searchText.isEmpty || $0.label.lowercased().contains(searchText.lowercased()) } ?? []
    }
}

struct entityListOptionsView: View {
    var entity: EntityRelationshipItem
    @Binding var value: [EntityRelationshipItem]
    var isSelected: Bool

    var body: some View {
        VStack {
            Button(action: {
                if isSelected {
                    value.removeAll{ $0.id == entity.id}
                } else {
                    let selectedValue: SelectValue = SelectValue(
                        label: entity.label, id: entity.id, translatedLabel: entity.label, values: []
                    )
                    value.append(entity)
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
    EntitySelectorView(selectedValues: .constant([]))
}
