//
//  ResizableImage.swift
//  Tella
//
//  Created by RIMA on 14.11.24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResizableImage: View {
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        Image(name)
            .resizable()
    }
}

