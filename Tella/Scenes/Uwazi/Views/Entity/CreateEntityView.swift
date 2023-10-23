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
    
    init(appModel: MainAppModel, templateId: Int, server: Server) {
        _entityViewModel = StateObject(wrappedValue: UwaziEntityViewModel(mainAppModel: appModel, templateId:templateId, server: server))
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
            UwaziDividerWidget()
            bottomActionView
        }
    }

    fileprivate var createEntityHeaderView: some View {
        CreateDraftHeaderView(title: entityViewModel.template!.entityRow?.name ?? "",
                              isDraft: true,
                              closeAction: { showSaveEntityConfirmationView() },
                              saveAction: { })
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
    
    fileprivate var bottomActionView: some View {
        Button(action: {
            self.entityViewModel.handleMandatoryProperties()
        }) {
            Text(LocalizableUwazi.uwaziEntityActionNext.localized)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 32))
                .foregroundColor(Color.white)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func showSaveEntityConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: modelHeight) {
            ConfirmBottomSheet(titleText: LocalizableUwazi.uwaziEntityExitSheetTitle.localized,
                               msgText: LocalizableUwazi.uwaziEntityExitSheetExpl.localized,
                               cancelText: LocalizableReport.exitCancel.localized.uppercased(),
                               actionText: LocalizableReport.exitSave.localized.uppercased(),
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
