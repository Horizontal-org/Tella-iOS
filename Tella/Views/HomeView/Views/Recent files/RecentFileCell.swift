//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

protocol RecentFileProtocol {
    var thumbnailImage: UIImage {get}
    var iconImage: UIImage {get}
    var bigIconImage: UIImage {get}
    var recentGridImage: AnyView {get}
}

extension RecentFileProtocol {
    var recentGridImage: AnyView {
        AnyView(
            ZStack{
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .frame(width: 75, height: 75)

                Image(uiImage: bigIconImage)
                    .frame(width: 33, height: 33)
                    .aspectRatio(contentMode: .fit)
                
            }.background(Color.white.opacity(0.2))
        )
    }
}

struct RecentFileCell: View {
    let recentFile: RecentFileProtocol
    var body: some View {
        ZStack{
            recentFile.recentGridImage
                .frame(width: 75, height: 75)
        }

    }
}

struct LoadMoreCell: View {
    
    var fileNumber : Int?
    
    var body: some View {
        VStack(spacing: 5){
            Spacer()
            Image("home.load_more")
                .frame(width: 33, height: 33)
                .aspectRatio(contentMode: .fit)
            if let fileNumber = fileNumber {
                Text("\(fileNumber) more files")
                    .font(.custom(Styles.Fonts.regularFontName, size: 9))
                    .foregroundColor(.white)
            }
            Spacer()
        }
        .frame(width: 75, height: 75)
        .background(Color.white.opacity(0.2))
    }
}
