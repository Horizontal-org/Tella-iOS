//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct DeleteReportConfirmationView: View {
    
    var message : String
    var confirmAction : () -> ()
    
    var body: some View {
        
        ConfirmBottomSheet(titleText: LocalizableReport.deleteTitle.localized,
                           msgText: message,
                           cancelText: LocalizableReport.deleteCancel.localized,
                           actionText: LocalizableReport.deleteConfirm.localized, didConfirmAction: {
            
            confirmAction()
        })
    }
}

struct DeleteReportConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteReportConfirmationView(message: "Message") {
            
        }
    }
}
