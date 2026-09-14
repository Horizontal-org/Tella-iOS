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
            CustomText(LocalizableUwazi.uwaziEntityRelationshipExpl.localized,
                       style: .body2Style,
                       color: Color.white.opacity(0.80),
                       fillsWidth: true)
            
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
            UwaziActionRow(icon: .uwaziAddFiles,
                           title: prompt.value.isEmpty ?
                           LocalizableUwazi.uwaziEntityRelationshipSelectTitle.localized :
                            LocalizableUwazi.uwaziEntityRelationshipAddMoreTitle.localized)
        }
    }
}

#Preview("Select entities") {
    ContainerView {
        UwaziRelationshipWidget(prompt: .stub(),
                                entityViewModel: .stub())
        .padding()
    }
}

#Preview("Selected entities") {
    let prompt = UwaziRelationshipEntryPrompt.stub()
    prompt.selectValues = [
        SelectValues(id: "1", label: "Entity one", values: nil),
        SelectValues(id: "2", label: "Entity two", values: nil)
    ]
    prompt.value = ["1", "2"]
    return ContainerView {
        UwaziRelationshipWidget(prompt: prompt,
                                entityViewModel: .stub())
        .padding()
    }
}
