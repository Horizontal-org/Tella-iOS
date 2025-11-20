//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct BackgroundActivitiesItemView: View {
    
    @Binding var item: BackgroundActivityModel

    var body: some View {
        
        HStack(alignment: .center, spacing: 12) {
            imageView
            nameView
        }
    }
    
    var imageView: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.white.opacity(0.2))
            .frame(width: 35, height: 35, alignment: .center)
            .overlay(
                ZStack {
                    if let thumb = item.thumb, let uiImage = UIImage(data:thumb) {
                        Image(uiImage:uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    Image(uiImage: item.mimeType.smallIconImage)
                }
                    .frame(width: 35, height: 35)
                    .cornerRadius(5)
            )
    }
    
    var nameView: some View {
        Text(item.name)
            .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
            .foregroundColor(Color.white)
            .lineLimit(1)
    }
}

#Preview {
    BackgroundActivitiesItemView(item: .constant( BackgroundActivityModel.stub()))
        .background(Styles.Colors.backgroundTab)
}
