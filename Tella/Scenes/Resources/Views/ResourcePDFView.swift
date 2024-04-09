//
//  ResourcePDFView.swift
//  Tella
//
//  Created by gus valbuena on 2/23/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct ResourcePDFView: View {
    var file: URL
    var resourceTitle: String
    @State private var navigationBarHidden = false
    var body: some View {
        ZStack {
            PDFKitView(url: file)
        }.toolbar {
            LeadingTitleToolbar(title: resourceTitle)
        }.gesture(DragGesture().onChanged { value in
            navigationBarHidden = value.translation.height < 0
        }).navigationBarHidden(navigationBarHidden)
    }
}

#Preview {
    ResourcePDFView(file: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.pdf"), resourceTitle: "resource title")
}
