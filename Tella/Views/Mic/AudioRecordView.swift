//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AudioRecordView: View {
    @ObservedObject var appModel : MainAppModel

    var body: some View {
        RecordView()
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(appModel.selectedTab == .home ? false : true)

    }
}
