//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ImageViewer: View {
    
    var imageData : Data?
    
    var body: some View {
        
        GeometryReader { geometry in
            VStack(alignment: .center) {
                Spacer()
                UIImage.image(fromData: imageData ?? Data())
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
    }
}

