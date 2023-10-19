//
//  DeleteTemplateConfirmationView.swift
//  Tella
//
//  Created by Robert Shrestha on 8/22/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DeleteTemplateConfirmationView: View {
    var viewModel: DeleteTemplateConfirmationViewModel
    var body: some View {
        let titleText = LocalizableReport.viewModelDelete.localized + " " + "\"\(viewModel.title)\""
        ConfirmBottomSheet(titleText: titleText,
                           msgText: viewModel.message,
                           cancelText: LocalizableReport.deleteCancel.localized,
                           actionText: LocalizableReport.deleteConfirm.localized, didConfirmAction: {

            viewModel.confirmAction()
        })
    }
}

struct DeleteTemplateConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteTemplateConfirmationView(viewModel: DeleteTemplateConfirmationViewModel(title: "", message: "", confirmAction: {
            print("")
        }))
    }
}
