//
//  CreateEntityView.swift
//  Tella
//
//  Created by Gustavo on 24/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CreateEntityView: View {
    var template : CollectedTemplate
    @EnvironmentObject var sheetManager : SheetManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
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
            
            CreateDraftHeaderView(title: template.entityRow?.name ?? "",
                                  isDraft: true,
                                  closeAction: { showSaveEntityConfirmationView() },
                                  saveAction: {})
    }
    
    var draftContentView: some View {
        
        ZStack {
            VStack {
                ForEach(template.entityRow!.properties, id: \.id) { property in
                    renderPropertyComponent(
                        propertyType: property.type ?? "",
                        label: property.label ?? "",
                        property: property,
                        commonProperty: nil
                    )
                }
                    
                ForEach(template.entityRow!.commonProperties, id: \.id) { commonProperty in
                    renderPropertyComponent(
                        propertyType: commonProperty.type ?? "",
                        label: commonProperty.label ?? "",
                        property: nil,
                        commonProperty: commonProperty
                    )
                    }
                }
        }
    }
    
    @ViewBuilder
    private func renderPropertyComponent(
        propertyType: String,
        label: String, property: Property?,
        commonProperty: CommonProperty?
    ) -> some View {
        switch propertyType{
        case UwaziConstants.dataTypeText.rawValue, UwaziConstants.dataTypeNumeric.rawValue:
            //render textFieldComponent
            Text(label)
        case UwaziConstants.dataTypeDate.rawValue, UwaziConstants.dataTypeDateRange.rawValue,
             UwaziConstants.dataTypeMultiDate.rawValue, UwaziConstants.dataTypeMultiDateRange.rawValue:
            Text(label)
        case UwaziConstants.dataTypeSelect.rawValue, UwaziConstants.dataTypeMultiSelect.rawValue:
            Text(label)
        case UwaziConstants.dataTypeLink.rawValue:
            Text(label)
        case UwaziConstants.dataTypeImage.rawValue:
            Text(label)
        case UwaziConstants.dataTypeGeolocation.rawValue:
            Text(label)
        case UwaziConstants.dataTypePreview.rawValue:
            Text(label)
        case UwaziConstants.dataTypeMedia.rawValue:
            Text(label)
        case UwaziConstants.dataTypeMarkdown.rawValue:
            Text(label)
        case UwaziConstants.dataTypeMultiFiles.rawValue, UwaziConstants.dataTypeMultiPDFFiles.rawValue:
            Text(label)
        case UwaziConstants.dataTypeGeneratedID.rawValue:
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
