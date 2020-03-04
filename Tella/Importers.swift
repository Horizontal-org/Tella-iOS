//
//  Coordinator.swift
//  Tella
//
//  Created by Erin Simshauser on 2/18/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//
import SwiftUI
import Photos

struct ImagePickerView: UIViewControllerRepresentable {
    
    let back: () -> ()

    func makeCoordinator() -> ImageCoordinator {
        print("make coordinator called")
      return ImageCoordinator(back)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) ->
        UIImagePickerController {
            print("makeUIViewController called")
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePickerView>) {
        print("update UIViewController")
    }
}

class ImageCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let back: () -> ()
    
    init(_ back: @escaping () -> ()) {
        self.back = back
    }
    
//  this function gets called when user selects an image
    func imagePickerController(_ picker: UIImagePickerController,
                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        TellaFileManager.saveImage(unwrapImage)
        back()
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        back()
    }
}

struct DocPickerView: UIViewControllerRepresentable {
    
    let back: () -> ()

    func makeCoordinator() -> DocCoordinator {
        return DocCoordinator(back)
    }

    //initialize docPicker with specified document types and mode as import
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        print("make UIViewController called")
        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        docPicker.delegate = context.coordinator
        return docPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocPickerView>) {}
}

//coordinator acts as the go between for swiftui and uikit
class DocCoordinator: NSObject, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    let back: () -> ()
    
    init(_ back: @escaping () -> ()) {
        self.back = back
    }
    
//  this function called on document click
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            print("Failed to retrieve url")
            return
        }
        TellaFileManager.copyExternalFile(url)
        back()
    }
    //called when cancel button pressed
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        back()
    }

}
