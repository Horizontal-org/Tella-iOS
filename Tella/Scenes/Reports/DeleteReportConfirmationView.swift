//
//  DeleteReportConfirmationView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 7/3/2023.
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DeleteReportConfirmationView: View {
  
    var confirmAction : () -> ()
   
    var body: some View {
            
        ConfirmBottomSheet(titleText: LocalizableReport.deleteTitle.localized,
                           msgText: LocalizableReport.deleteMessage.localized,
                           cancelText: LocalizableReport.deleteCancel.localized,
                           actionText: LocalizableReport.deleteConfirm.localized, didConfirmAction: {
            
            confirmAction()
        })
     }
}

struct DeleteReportConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteReportConfirmationView {
            
        }
    }
}
