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
        case UwaziConstants.dataTypeDate.rawValue, UwaziConstants.dataTypeDateRange.rawValue,
             UwaziConstants.dataTypeMultiDate.rawValue, UwaziConstants.dataTypeMultiDateRange.rawValue:
            Title(label: label)
        case UwaziConstants.dataTypeSelect.rawValue, UwaziConstants.dataTypeMultiSelect.rawValue:
            Title(label: label)
        case UwaziConstants.dataTypeLink.rawValue:
            Title(label: label)
        case UwaziConstants.dataTypeImage.rawValue:
            Title(label: label)
        case UwaziConstants.dataTypeGeolocation.rawValue:
            Title(label: label)
        case UwaziConstants.dataTypePreview.rawValue:
            Title(label: label)
        case UwaziConstants.dataTypeMedia.rawValue:
            Title(label: label)
        case UwaziConstants.dataTypeMarkdown.rawValue:
            Title(label: label)
        case UwaziConstants.dataTypeMultiFiles.rawValue:
            Title(label: label)
            Subtitle(label: "Select as many files as you wish")
        case UwaziConstants.dataTypeMultiPDFFiles.rawValue:
            Title(label: label)
            Subtitle(label: "Select as many PDF files as you wish")
        case UwaziConstants.dataTypeGeneratedID.rawValue:
            Title(label: label)
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
