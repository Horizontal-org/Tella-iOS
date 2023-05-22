//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct EmptyReportView: View {
    
    var message : String
    
    var body: some View {
        VStack(alignment: .center, spacing: 22) {
            Image("reports.report")
            Text(message)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }.padding(EdgeInsets(top: 0, leading: 31, bottom: 0, trailing: 31))
    }
}

struct EmptyReportView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Styles.Colors.backgroundMain
            EmptyReportView(message: LocalizableReport.draftEmptyMessage.localized)
        }
    }
}
