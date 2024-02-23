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
    var body: some View {
        ZStack {
            QuickLookView(file: file)
        }.toolbar {
            LeadingTitleToolbar(title: resourceTitle)
        }
    }
}

#Preview {
    
    ResourcePDFView(file: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.pdf"), resourceTitle: "resource title")
}
