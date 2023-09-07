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
                    RenderPropertyComponentView(
                        label: property.label ?? "",
                        propertyType: property.type ?? "",
                        property: property
                    ).environmentObject(entityViewModel)
                }
                ForEach(entityViewModel.template.entityRow!.commonProperties, id: \.id) { commonProperty in
                    RenderPropertyComponentView(
                        label: commonProperty.label ?? "",
                        propertyType: commonProperty.type ?? "",
                        commonProperty: commonProperty
                    ).environmentObject(entityViewModel)
                }
            }.padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
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
