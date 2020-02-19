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

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let docPicker = UIDocumentPickerViewController(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item","public.data", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content", "com.adobe.pdf"], in: .import)
        docPicker.delegate = context.coordinator
        return docPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {

    }

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
            //do something with the doc object above probably
            print("a")
            print(urls)
            guard let url = urls.first else {
                return
            }
            if let resourceValues = try? url.resourceValues(forKeys: [.typeIdentifierKey]),
                let uti = resourceValues.typeIdentifier {
                print(uti)
            }
            isDocCoordinatorShown = false
        }
        
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
    
    @State var doc: NSObject? = nil
    @State private var showingDocPicker = false
    
    @State var showingSheet: Bool = false
    
    
    let back: Button<AnyView>
        
    var body: some View {
            
        let first = File(name: "File 1")
        let second = File(name: "File 2")
        let third = File(name: "File 3")
        let files = [first, second, third]
        
        return Group {
                
            HStack {
                back
                Spacer()
                mediumText("GALLERY")
                Spacer()
                Button(action: {
                    print("shutdown button pressed")
                }) {
                    mediumImg(.SHUTDOWN)
                }
            }

            Spacer().frame(maxHeight: 50)

            HStack {
                Button(action: {
                    print("list icon pressed")
                }) {
                    smallImg(.LIST)
                    smallText("List view")
                }
                Spacer().frame(maxWidth: 40)
                Button(action: {
                    print("grid icon pressed")
                }) {
                    smallImg(.GRID)
                    smallText("Grid view")
                }
            }

            Spacer()
            List(files) { file in
                FileRow(file: file)

            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.showingSheet = true
                }) {
                    bigImg(.PLUS)
                }
                .actionSheet(isPresented: $showingSheet) {
                    //creates the popup on plus button, giving options of where to import from
//                    let alertController = UIAlertController(title: "Import from...", message: nil, preferredStyle: .actionSheet)
//                    alertController.addAction(UIAlertAction(title: "Files", style: .default, handler: self.showingDocPicker.toggle())
                    ActionSheet(title: Text("Import from..."), message: nil, buttons: [
                        .default(Text("Files")) { self.showingDocPicker.toggle() },
                        .default(Text("Photos")) { self.showCaptureImageView.toggle() },
                        //.default(Text("Voice Memos")) { },
                        .cancel()
                    ])
                }
                .sheet(isPresented: $showingDocPicker) {
                    DocPicker(isDocShown: self.$showingDocPicker, doc: self.$doc)
                
                }
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
        Text("\(file.name)").font(.custom("Avenir Next Ultra Light", size: 20)).foregroundColor(.black)
    }
}
