//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct DeleteReportConfirmationView: View {
    
    var title : String?
    var message : String
    var confirmAction : () -> ()
    
    var body: some View {
        
        ConfirmBottomSheet(titleText: String.init(format: LocalizableReport.deleteTitle.localized, title ?? ""),
                           msgText: message,
                           cancelText: LocalizableReport.deleteCancel.localized,
                           actionText: LocalizableReport.deleteConfirm.localized, didConfirmAction: {
            
            confirmAction()
        })
    }
}

struct DeleteReportConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteReportConfirmationView(title: "Title", message: "Message") {
            
        }
    }
}
