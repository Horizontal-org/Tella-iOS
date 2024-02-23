//
//  Copyright © 2021 INTERNEWS. All rights reserved.
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

