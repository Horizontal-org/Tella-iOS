//
//  EntitySelectorView.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct EntitySelectorView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var prompt: UwaziRelationshipEntryPrompt
    @State private var searchText: String = ""
    
    var body: some View {
        ContainerViewWithHeader {
            navigationBarView
        } content: {
            contentView
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: prompt.question,
                             rightButtonType: prompt.value.isEmpty ? .none : .validate,
                             rightButtonAction: {presentationMode.wrappedValue.dismiss()})
    }
    
    var contentView: some View {
        VStack {
            SearchBarView(searchText: $searchText, placeholderText: LocalizableUwazi.uwaziRelationshipSearchTitle.localized)
            Text(LocalizableUwazi.uwaziRelationshipListExpl.localized)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white.opacity(0.87))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            ScrollView {
                ForEach(filteredEntities()) {entity in
                    entityListOptionsView(entity: entity,
                                          isSelected: isSelected(entity: entity),
                                          value: $prompt.value
                    )
                }
            }
            Spacer()
        }
    }
    
    func isSelected(entity: SelectValues) -> Bool {
        if prompt.value.contains(where: { $0 == entity.id}) { return true }
        return false
    }
    
    func filteredEntities() -> [SelectValues] {
        return prompt.selectValues?.filter { searchText.isEmpty || ($0.label.lowercased().contains(searchText.lowercased())) } ?? []
    }
}

struct entityListOptionsView: View {
    
    var entity: SelectValues
    var isSelected: Bool
    @Binding var value: [String]
    
    var body: some View {
        VStack {
            Button(action: {
                if isSelected {
                    value.removeAll{ $0 == entity.id}
                } else {
                    value.append(entity.id)
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
    EntitySelectorView(prompt: UwaziRelationshipEntryPrompt.stub())
}
