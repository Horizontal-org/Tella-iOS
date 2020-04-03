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

