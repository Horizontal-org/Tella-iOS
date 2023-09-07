//
//  RenderPropertyComponentView.swift
//  Tella
//
//  Created by Gustavo on 07/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct RenderPropertyComponentView: View {
    @EnvironmentObject var entityViewModel : DraftUwaziEntity
    var label : String
    var propertyType: String
    var commonProperty: CommonProperty?
    var property: Property?
    
    var body: some View {
        renderPropertyComponent(
            propertyType: propertyType,
            label: label,
            property: property ?? nil,
            commonProperty: commonProperty ?? nil
        )
    }
    
    @ViewBuilder
    private func renderPropertyComponent(
        propertyType: String,
        label: String, property: Property?,
        commonProperty: CommonProperty?
    ) -> some View {
        switch UwaziEntityPropertyType(rawValue: propertyType) {
        case .dataTypeText, .dataTypeNumeric:
            Title(label: label)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white)
            TextfieldView(
                fieldContent:
                    entityViewModel.bindingForLabel(label),
                    isValid: $entityViewModel.isValidText,
                    shouldShowError: $entityViewModel.shouldShowError,
                    fieldType: .text
            )
        case .dataTypeDate, .dataTypeDateRange, .dataTypeMultiDate, .dataTypeMultiDateRange:
            Text(label)
        case .dataTypeSelect, .dataTypeMultiSelect:
            Text(label)
        case .dataTypeLink:
            Text(label)
        case .dataTypeImage:
            Text(label)
        case .dataTypeGeolocation:
            Text(label)
        case .dataTypePreview:
            Text(label)
        case .dataTypeMedia:
            Text(label)
        case .dataTypeMarkdown:
            Text(label)
        case .dataTypeMultiFiles, .dataTypeMultiPDFFiles:
            Text(label)
        case .dataTypeGeneratedID:
            Text(label)
        default:
            Group {
                Text("Unsupported property type")
            }
        }
    }
    
    @ViewBuilder
    private func Title(
        label: String
    ) -> some View {
        Text(label)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .foregroundColor(Color.white)
    }
    
    @ViewBuilder
    private func Subtitle(
        label: String
    ) -> some View {
        Text(label)
            .font(.custom(Styles.Fonts.regularFontName, size: 12))
            .foregroundColor(Color.white.opacity(0.8))
    }
}
