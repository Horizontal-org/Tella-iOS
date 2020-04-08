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
    
    @State var filename: String = ""
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
            HStack{
                Spacer()
                TextField(
                    "Rename",
                    text: $filename,
                    onCommit: {TellaFileManager.rename(original: self.filepath, new: self.filename, type: self.filepath.components(separatedBy: ".")[1])}
                )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                back
            }
            Spacer()
            getPreview()
            Spacer()
        }
    }
}

