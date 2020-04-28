//
//  PreviewView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/25/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//


/*
 This class represents the Preview view used in the gallery view. It will automatically handle any file type with a built in fallback for unrecognized file types
 */

import Foundation
import SwiftUI
import PDFKit

struct PreviewView: View {
    @State private var shutdownWarningDisplayed = false
    let back: Button<AnyView>
    let filepath: String
    let privKey: SecKey
    
    var fileType: FileTypeEnum? {
        return FileTypeEnum(rawValue: filepath.components(separatedBy: ".")[1])
    }
    
    func getPreview() -> AnyView {
        switch fileType {
        case .IMAGE:
            if let img = TellaFileManager.recoverImageFile(filepath, privKey) {
                return AnyView(Image(uiImage: img).resizable().scaledToFit())
            }
            return AnyView(smallText("Image could not be recovered"))
        case .VIDEO:
            return AnyView(smallText("Video preview not available"))
        case .TEXT:
            let txt = TellaFileManager.recoverTextFile(filepath, privKey)
            return AnyView(
                ScrollView(.vertical) {
                    smallText(txt ?? "Could not recover text")
                }
            )
        case .PDF:
            if let data = TellaFileManager.recoverAndDecrypt(filepath, privKey) {
                return AnyView(PDFKitView(data: data))
            } else {
                return smallText("Data not found")
            }
        default:
            return AnyView(smallText("Unrecognized Type"))
        }
    }
    
    var body: some View {
        return Group {
            header(back, "PREVIEW", shutdownWarningPresented: $shutdownWarningDisplayed)
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
