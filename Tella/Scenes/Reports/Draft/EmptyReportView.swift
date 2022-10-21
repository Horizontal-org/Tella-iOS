//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct EmptyReportView: View {
    
    
    var body: some View {
        VStack(spacing: 22) {
            Image("reports.report")
            Text("Your Drafts is currently empty. Reports that you have not submitted will appear here.")
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
            EmptyReportView()
        }
    }
}
