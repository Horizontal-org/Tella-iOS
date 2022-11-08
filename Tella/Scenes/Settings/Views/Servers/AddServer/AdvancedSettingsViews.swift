//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ShareInfoView: View {
    
    @Binding var shareInfo : Bool
    
    var body: some View {
        SettingToggleItem(title: "Share verification information",
                          description: "Include information about your device and location when sending reports, to make your files verifiable. ",
                          toggle: $shareInfo)
    }
}

struct BackgroundUploadView:  View {
    
    @Binding var backgroundUpload : Bool
    
    var body: some View {
        
        SettingToggleItem(title: "Background upload",
                          description: "Continue uploading reports while doing other tasks or if you exit Tella.\n\nWARNING: If enabled, Tella will remain unlocked until all reports are fully uploaded.",
                          toggle: $backgroundUpload)
    }
}



struct ShareInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ShareInfoView(shareInfo: .constant(true))
    }
}
