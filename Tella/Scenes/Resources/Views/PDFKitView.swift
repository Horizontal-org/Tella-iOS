//
//  PDFKitView.swift
//  Tella
//
//  Created by gus valbuena on 3/14/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI
import PDFKit

struct PDFKitView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {}
}


#Preview {
    PDFKitView(url:URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.pdf"))
}
