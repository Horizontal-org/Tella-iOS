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
                    .frame(width: 70, height: 70, alignment: .center)
                    .clipped()
                Image(uiImage: bigIconImage)
                    .frame(width: 33, height: 33)
                    .aspectRatio(contentMode: .fit)

            }
            .frame(width: 70, height: 70, alignment: .center)
            .background(Color.gray)
        )
    }
}

struct RecentFileCell: View {
    let recentFile: RecentFileProtocol
    var body: some View {
        ZStack{
            recentFile.recentGridImage
                .frame(width: 70, height: 70)
        }
    }
}

struct LoadMoreCell: View {
    
    var onClick : (() -> Void)?
    
    var body: some View {
        Button {
            onClick?()
        } label: {
            VStack(spacing: 5){
                Spacer()
                Image("home.load_more")
                    .frame(width: 33, height: 33)
                    .aspectRatio(contentMode: .fit)
                Text("27 more files")
                    .font(.custom(Styles.Fonts.regularFontName, size: 9))
                    .foregroundColor(.white)
                Spacer()

            }

        }

    }
}
