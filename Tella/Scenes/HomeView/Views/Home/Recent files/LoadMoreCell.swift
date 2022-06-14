//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct LoadMoreCell: View {
    
    var fileNumber : Int?
    
    var body: some View {
        VStack(spacing: 5){
            Spacer()
            Image("home.load_more")
                .frame(width: 33, height: 33)
                .aspectRatio(contentMode: .fit)
            if let fileNumber = fileNumber {
                Text(String.init(format: LocalizableHome.recentFiles_MoreFiles.localized, fileNumber))   
                    .font(.custom(Styles.Fonts.regularFontName, size: 9))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .frame(width: 75, height: 75)
        .background(Color.white.opacity(0.2))
    }
}

struct LoadMoreCell_Previews: PreviewProvider {
    static var previews: some View {
        LoadMoreCell()
    }
}
