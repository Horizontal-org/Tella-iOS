//
//  Copyright © 2023 INTERNEWS. All rights reserved.
//

import SwiftUI

struct DeleteReportConfirmationView: View {
  
    var confirmAction : () -> ()
   
    var body: some View {
            
        ConfirmBottomSheet(titleText: "Delete report",
                           msgText: "Are you sure you want to delete this draft?",
                           cancelText: "CANCEL",
                           actionText: "DELETE", didConfirmAction: {
            
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
