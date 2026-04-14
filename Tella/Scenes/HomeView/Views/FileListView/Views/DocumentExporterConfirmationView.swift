//
//  DocumentExporterConfirmationView.swift
//  Tella
//
//  Created by Amine Info on 3/2/2022.
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DocumentExporterConfirmationView: View {
    @Binding var showingSaveConfirmationSheet : Bool
    @Binding var showingDocumentPicker : Bool
    @EnvironmentObject var appModel: MainAppModel

    
    var body: some View {
        ConfirmBottomSheet(titleText: LocalizableVault.saveToDeviceSheetTitle.localized,
                           msgText: LocalizableVault.saveToDeviceSheetExpl.localized,
                           cancelText: LocalizableVault.saveToDeviceCancelSheetAction.localized,
                           actionText: LocalizableVault.saveToDeviceSaveSheetAction.localized,
//                           modalHeight: 180,
                           isPresented: $showingSaveConfirmationSheet,
                           didConfirmAction: {
            showingSaveConfirmationSheet = false
            showingDocumentPicker = true
 
        })
    }
}

//struct DocumentExporterConfirmationView_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentExporterConfirmationView()
//    }
//}
