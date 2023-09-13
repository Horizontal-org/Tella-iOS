//
//  DeleteTemplateConfirmationView.swift
//  Tella
//
//  Created by Robert Shrestha on 8/22/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DeleteTemplateConfirmationView: View {
    var title : String?
    var message : String
    var confirmAction : () -> ()

    var body: some View {
        let titleText = LocalizableReport.viewModelDelete.localized + " " + "\"\(title ?? "")\""
        ConfirmBottomSheet(titleText: titleText,
                           msgText: message,
                           cancelText: LocalizableReport.deleteCancel.localized,
                           actionText: LocalizableReport.deleteConfirm.localized, didConfirmAction: {

            confirmAction()
        })
    }
}

struct DeleteTemplateConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteTemplateConfirmationView(message: "", confirmAction: {})
    }
}
