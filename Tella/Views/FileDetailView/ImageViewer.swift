//
//  ImageViewer.swift
//  Tella
//
//  Created by Ahlem on 30/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ImageViewer: View {
    var imageData: Data?
    
    var body: some View {
        GeometryReader { geo in
            NSUIImage.image(fromData: imageData ?? Data())
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fit)
                .frame(width: geo.size.width)
        }
    }
}




