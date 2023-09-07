//
//  CreateEntityView.swift
//  Tella
//
//  Created by Gustavo on 24/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CreateEntityView: View {
    @StateObject var entityViewModel : DraftUwaziEntity
    @EnvironmentObject var sheetManager : SheetManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(mainAppModel: MainAppModel, template: CollectedTemplate) {
        _entityViewModel = StateObject(wrappedValue: DraftUwaziEntity(mainAppModel: mainAppModel, template: template))
    }
    var body: some View {
        ContainerView {
            contentView
        }
        .navigationBarHidden(true)
    }
    
    var contentView: some View {
        VStack(alignment: .leading) {
            createEntityHeaderView
            draftContentView
            Spacer()
        }
    }
    
    var createEntityHeaderView: some View {
        
        CreateDraftHeaderView(title: entityViewModel.template.entityRow?.name ?? "",
                              isDraft: true,
                              closeAction: { showSaveEntityConfirmationView() },
                              saveAction: {})
    }
    
    var draftContentView: some View {
        
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(entityViewModel.template.entityRow!.properties, id: \.id) { property in
                    renderPropertyComponent(
                        propertyType: property.type ?? "",
                        label: property.translatedLabel ?? "",
                        property: property,
                        commonProperty: nil
                    )
                }
                ForEach(entityViewModel.template.entityRow!.commonProperties, id: \.id) { commonProperty in
                    renderPropertyComponent(
                        propertyType: commonProperty.type ?? "",
                        label: commonProperty.translatedLabel ?? "",
                        property: nil,
                        commonProperty: commonProperty
                    )
                }
            }.padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
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
    
    
    @ViewBuilder
    private func renderPropertyComponent(
        propertyType: String,
        label: String, property: Property?,
        commonProperty: CommonProperty?
    ) -> some View {
        switch UwaziEntityPropertyType(rawValue: propertyType) {
        case .dataTypeText, .dataTypeNumeric:
            //render textFieldComponent
            
            Title(label: label)
                            .font(.custom(Styles.Fonts.regularFontName, size: 14))
                            .foregroundColor(Color.white)
                        TextfieldView(
                            fieldContent: entityViewModel.bindingForLabel(label),
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

    
    private func showSaveEntityConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: "Exit entity?",
                               msgText: "Your draft will be lost",
                               cancelText: LocalizableReport.exitCancel.localized,
                               actionText: LocalizableReport.exitSave.localized,
                               didConfirmAction: {
                
            }, didCancelAction: {
                dismissViews()
            })
        }
    }
    
    private func dismissViews() {
        sheetManager.hide()
        self.presentationMode.wrappedValue.dismiss()
    }
}
