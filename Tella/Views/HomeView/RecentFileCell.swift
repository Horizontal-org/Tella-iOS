//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

protocol RecentFileProtocol {
    var thumbnailImage: UIImage {get}
    var iconImage: UIImage {get}
    var gridImage: AnyView {get}
}

extension RecentFileProtocol {
    var gridImage: AnyView {
        AnyView(
            ZStack{
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70, alignment: .center)
                    .clipped()
                Image(uiImage: iconImage)
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
            recentFile.gridImage
                .frame(width: 70, height: 70)
        }
        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
//        .padding(.leading, 5)
    }
}
