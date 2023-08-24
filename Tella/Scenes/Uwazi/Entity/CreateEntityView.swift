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
            
            Spacer()
        }
    }
    
    var createEntityHeaderView: some View {
            
            CreateDraftHeaderView(title: template.entityRow?.name ?? "",
                                  isDraft: true,
                                  closeAction: { showSaveEntityConfirmationView() },
                                  saveAction: {})
        }
    
    private func showSaveEntityConfirmationView() {
        sheetManager.showBottomSheet(modalHeight: 200) {
            ConfirmBottomSheet(titleText: "Exit entity?",
                               msgText: "Your draft will be lost",
                               cancelText: "EXIT ANYWAY",
                               actionText: "SAVE AND EXIT",
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
