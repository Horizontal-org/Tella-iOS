//
//  CreateEntityView.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CreateEntityView: View {
    @StateObject var entityViewModel : UwaziEntityViewModel
    @EnvironmentObject var sheetManager : SheetManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let modelHeight = 200.0
    
    init(template: CollectedTemplate) {
        _entityViewModel = StateObject(wrappedValue: UwaziEntityViewModel(template: template,
                                                                          parser: UwaziEntityParser(template: template)))
    }
    var body: some View {
        ContainerView {
            contentView
        }
        .navigationBarHidden(true)
    }
    
    fileprivate var contentView: some View {
        VStack(alignment: .leading) {
            createEntityHeaderView
            draftContentView
            Spacer()
        }
    }

    fileprivate var createEntityHeaderView: some View {
        CreateDraftHeaderView(title: entityViewModel.template.entityRow?.name ?? "",
                              isDraft: true,
                              closeAction: { showSaveEntityConfirmationView() },
                              saveAction: { self.entityViewModel.handleMandatoryProperties() })
    }


    
    fileprivate var draftContentView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(entityViewModel.entryPrompts, id: \.id) { prompt in
                        RenderPropertyComponentView(prompt: prompt)
                    }
                }.padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
            }
        }
    }

    private func showSaveEntityConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: modelHeight) {
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
