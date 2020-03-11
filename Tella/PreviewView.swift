//
//  PreviewView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/25/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//
import SwiftUI
import PDFKit

struct PreviewView: View {
    
    let back: Button<AnyView>
    let filepath: String
    var fileType: FileTypeEnum? {
        return FileTypeEnum(rawValue: filepath.components(separatedBy: ".")[1])
    }
    
    func getPreview() -> AnyView {
        return AnyView(QuickLookView(name: "Preview", file: filepath))
//        switch fileType {
//
//        case .IMAGE:
//            if let img = TellaFileManager.recoverImageFile(filepath) {
//                return AnyView(Image(uiImage: img).resizable().scaledToFit())
//            }
//            return AnyView(smallText("Image could not be recovered"))
//        case .VIDEO:
//            return AnyView(smallText("Video preview not available"))
//        case .TEXT:
//            return AnyView(smallText("Text preview not available"))
//        case .PDF:
//            if let data = TellaFileManager.recoverData(filepath) {
//                return AnyView(PDFKitView(data: data))
//            } else {
//                return smallText("Data not found")
//            }
//        default:
//            return AnyView(smallText("Unrecognized Type"))
//        }
    }
    
    var body: some View {
        return Group {
            header(back, "PREVIEW")
            Spacer()
            getPreview()
            Spacer()
        }
    }
}

struct PDFKitView : UIViewRepresentable {
    
    let data: Data
    
    func makeUIView(context: Context) -> UIView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        return pdfView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
}
