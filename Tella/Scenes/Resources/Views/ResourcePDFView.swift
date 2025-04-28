//
//  ResourcePDFView.swift
//  Tella
//
//  Created by gus valbuena on 2/23/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct ResourcePDFView: View {
    var file: URL
    var resourceTitle: String
    @State private var navigationBarHidden = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        
        ContainerViewWithHeader {
            navigationBarHidden ? nil : navigationBarView
        } content: {
            PDFKitView(url: file)
                .gesture(DragGesture().onChanged { value in
                    navigationBarHidden = value.translation.height < 0
                })
        }
    }
    
    var navigationBarView: some View {
        NavigationHeaderView(title: resourceTitle)
    }
}

#Preview {
    ResourcePDFView(file: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.pdf"), resourceTitle: "resource title")
}
