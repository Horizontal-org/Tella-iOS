//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

extension VaultFile {
    var gridImage: AnyView {
        AnyView(
            GeometryReader { geometryReader in
                ZStack{
                    Image(uiImage: self.thumbnailImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                    
                    Image(uiImage: self.bigIconImage)
                        .frame(width: 33, height: 33)
                        .aspectRatio(contentMode: .fit)
                    
                }.background(Color.white.opacity(0.2))
                    .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                    .clipped()
            }
        )
    }
}

extension VaultFile {
    var listImage: AnyView {
        AnyView(
            ZStack{
                Image(uiImage: thumbnailImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                Image(uiImage: iconImage)
            }
        )
    }
}

