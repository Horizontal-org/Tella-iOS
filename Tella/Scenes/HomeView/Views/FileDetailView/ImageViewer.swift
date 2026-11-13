//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ImageViewer: View {
    
    var imageData: Data?

    @available(iOS 17.0, *)
    private static let hdrImageReader: UIImageReader = {
        var configuration = UIImageReader.Configuration()
        configuration.prefersHighDynamicRange = true
        return UIImageReader(configuration: configuration)
    }()
    
    var body: some View {
        ZoomableImageView(image: image)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var image: UIImage? {
        guard let imageData else { return nil }
        if #available(iOS 17.0, *), let image = Self.hdrImageReader.image(data: imageData) {
            return image
        }
        return UIImage(data: imageData)
    }
}
