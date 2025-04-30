//
//  ResizableImage.swift
//  Tella
//
//  Created by RIMA on 14.11.24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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

