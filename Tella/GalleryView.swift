//
//  GalleryView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI
import UIKit

//creating struct
struct CaptureImageView {
    @Binding var isShown: Bool
    @Binding var image: Image?
    func makeCoordinator() -> Coordinator {
      return Coordinator(isShown: $isShown, image: $image)
    }

}
extension CaptureImageView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<CaptureImageView>) {

    }
}

struct DocPicker: UIViewControllerRepresentable {

    typealias UIViewControllerType = UIDocumentPickerViewController
    @Binding var isDocShown: Bool
    @Binding var doc: NSObject?

    func makeCoordinator() -> DocPicker.Coordinator {
        Coordinator(isDocShown: $isDocShown, doc: $doc, self)

    }

    //initialize docPicker with specified document types and mode as import
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let docPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "com.adobe.pdf"], in: .import)
        docPicker.delegate = context.coordinator
        return docPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {

    }

    //coordinator acts as the go between for swiftui and uikit
    class Coordinator: NSObject, UINavigationControllerDelegate, UIDocumentPickerDelegate {

        @Binding var docInCoordinator: NSObject?
        @Binding var isDocCoordinatorShown: Bool
        var parent: DocPicker
        init(isDocShown: Binding<Bool>, doc: Binding<NSObject?>, _ pickerController: DocPicker) {
            _isDocCoordinatorShown = isDocShown
            _docInCoordinator = doc

            self.parent = pickerController

        }
        //this function called on document click
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            print("a")
            guard let url = urls.first else {
                return
            }
            if let resourceValues = try? url.resourceValues(forKeys: [.typeIdentifierKey]),
                let uti = resourceValues.typeIdentifier {
                print(uti)
            }
            isDocCoordinatorShown = false
        }
        //called when cancel button pressed
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("cancelled")
            isDocCoordinatorShown = false
        }

    }
}

struct GalleryView: View {

    @State var image: Image? = nil
    @State var showFileImageView: Bool = false
    @State var showCaptureImageView: Bool = false

    let back: Button<AnyView>
    let files = [File(name: "File 1"), File(name: "File 2"), File(name: "File 3")]

    @State var doc: NSObject? = nil
    @State private var showingDocPicker = false
    @State var showingSheet: Bool = false


    var body: some View {

        let first = File(name: "File 1")
        let second = File(name: "File 2")
        let third = File(name: "File 3")
        let files = [first, second, third]

        return Group {
            header(back, "GALLERY")
            Spacer().frame(maxHeight: 50)
            HStack {
                smallLabeledImageButton(.LIST, "List view") {
                    print("list icon pressed")
                }
                Spacer().frame(maxWidth: 40)
                smallLabeledImageButton(.GRID, "Grid view") {
                    print("grid icon pressed")
                }
            }
            Spacer()
            List(files) { file in
                smallText(file.name)
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.showingSheet = true
                }) {
                    //bigImg(.PLUS)
                    smallText("plus")
                }
                .actionSheet(isPresented: $showingSheet) {
                    //creates the popup on plus button, giving options of where to import from
                    ActionSheet(title: Text("Import from..."), message: nil, buttons: [
                        .default(Text("Files")) { self.showingDocPicker.toggle() },
                        .default(Text("Photos")) { self.showCaptureImageView.toggle() },
                        //.default(Text("Voice Memos")) { },
                        .cancel()
                    ])
                }
                    //presenting the document picker on top of the current view
                .sheet(isPresented: $showingDocPicker) {
                    DocPicker(isDocShown: self.$showingDocPicker, doc: self.$doc)

                }
                    //presenting the image view
                .sheet(isPresented: $showCaptureImageView) {
                    CaptureImageView(isShown: self.$showCaptureImageView, image: self.$image)

                }

            }
        }
        }

    }



//code to fix constraints bug found from: https://stackoverflow.com/questions/55653187/swift-default-alertviewcontroller-breaking-constraints
extension UIAlertController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        pruneNegativeWidthConstraints()
    }

    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}

struct File: Identifiable {
    var id = UUID()
    var name: String
}

struct FileRow: View {
    var file: File
    var body: some View {
        smallText(file.name)
    }
}
