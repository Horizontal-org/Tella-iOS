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

                    self.fileNameText
                    
                }.background(Color.white.opacity(0.2))
                    .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                    .clipped()
            }
        )
    }
    
    @ViewBuilder
    var fileNameText: some View {
        if self.type != .image || self.type != .video {
            VStack {
                Spacer()
                Text(self.fileName)
                    .font(.custom(Styles.Fonts.regularFontName, size: 11))
                    .foregroundColor(.white)
                    .lineLimit(1)
                Spacer()
                    .frame(height: 6)
            }.padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 18))
        }
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

