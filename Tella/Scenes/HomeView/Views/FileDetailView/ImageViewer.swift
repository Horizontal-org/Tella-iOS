//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ImageViewer: View {
    
    var imageData : Data?
    
    var body: some View {
        ZoomableImageView(image: imageData.flatMap(UIImage.init(data:)))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
