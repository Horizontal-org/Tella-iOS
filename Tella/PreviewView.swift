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

//overwriting the ~= function so that it takes a string and regex then returns a true if a match and false otherwise
extension String {
    static func ~= (lhs: String, rhs: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: rhs) else { return false }
        let range = NSRange(location: 0, length: lhs.utf16.count)
        return regex.firstMatch(in: lhs, options: [], range: range) != nil
    }
}

struct PreviewView: View {


    @State var filename: String = ""
    @State var alertType = PreviewViewEnum.INVALID
    @State var showAlert = false

    @State private var shutdownWarningDisplayed = false

    let back: Button<AnyView>
    let filepath: String
    let data: Data?

    @State private var isSharePresented: Bool = false

    init(back: Button<AnyView>, filepath: String, privKey: SecKey) {
        self.back = back
        self.filepath = filepath
        self.data = TellaFileManager.recoverAndDecrypt(filepath, privKey)
    }


    var fileType: FileTypeEnum? {
        return FileTypeEnum(rawValue: filepath.components(separatedBy: ".").last!)
    }

    func getPreview() -> AnyView {
        switch fileType {
        case .IMAGE:
            if let img = TellaFileManager.recoverImage(data) {
                return AnyView(Image(uiImage: img).resizable().scaledToFit())
            }
            return AnyView(smallText("Image could not be recovered"))
        case .VIDEO:
            return AnyView(smallText("Video previewing not yet supported"))
        case .AUDIO:
            return AnyView(smallText("Audio previewing not yet supported"))
        case .TEXT:
            let txt = TellaFileManager.recoverText(data)
            return AnyView(
                ScrollView(.vertical) {
                    smallText(txt ?? "Could not recover text")
                }
            )
        case .PDF:
            if let pdf = data {
                return AnyView(PDFKitView(data: pdf))
            } else {
                return smallText("Data not found")
            }
        default:
            return AnyView(smallText("Unrecognized Type"))
        }

    }

    var body: some View {
        return Group {

            VStack{
                mediumText((filepath as NSString).lastPathComponent)
            HStack{
                Spacer()
                TextField(
                    "Rename",
                    text: $filename,
                    onCommit: {
                        if self.filename ~= "^[a-zA-Z0-9_]*$"{
                            if TellaFileManager.rename(original: self.filepath, new: self.filename, type: self.filepath.components(separatedBy: ".")[1]){
                            } else {
                                self.showAlert = true
                                self.alertType = PreviewViewEnum.SAME
                            }
                        } else {
                            self.showAlert = true
                            self.alertType = PreviewViewEnum.INVALID
                        }
                    }
                )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Spacer()
                back
            }
            .alert(isPresented: $showAlert) {
                if self.alertType == PreviewViewEnum.INVALID {
                    return  Alert(title: Text("Failed to rename"), message: Text("Please enter a file name with valid characters (letters, numbers, underscores)"), dismissButton: .default(Text("OK")))
                } else {
                    return  Alert(title: Text("Failed to rename"), message: Text("Please enter a file name that is not currently in use"), dismissButton: .default(Text("OK")))
                }
            }
            Spacer()
            getPreview()
            Spacer()
            }

            header(back, "PREVIEW", shutdownWarningPresented: $shutdownWarningDisplayed)
            Spacer()
            getPreview()
            Spacer()
            roundedButton("EXPORT") {
                self.isSharePresented = self.data != nil
            }
            .sheet(isPresented: $isSharePresented, onDismiss: {
                print("Dismiss")
            }, content: {
                ActivityViewController(fileData: self.data!)
            })

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
