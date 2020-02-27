//
//  Coordinator.swift
//  Tella
//
//  Created by Erin Simshauser on 2/18/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI
import Photos

//creating struct
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var isShown: Bool
    @Binding var image: Image?
    

    
    func makeCoordinator() -> ImagePickerView.ImageCoordinator {
        print("make coordinator called")
      return ImageCoordinator(isShown: $isShown, image: $image)
    }
    
    class ImageCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var isCoordinatorShown: Bool
        @Binding var imageInCoordinator: Image?
        
        init(isShown: Binding<Bool>, image: Binding<Image?>) {
            _isCoordinatorShown = isShown
            _imageInCoordinator = image
            
        }
        //this function gets called when user selects an image
        func imagePickerController(_ picker: UIImagePickerController,
                    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            //this is getting the image from user selection
            guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            
            TellaFileManager.saveImage(unwrapImage)

            isCoordinatorShown = false
            
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            isCoordinatorShown = false
            
        }
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

struct DocPickerView: UIViewControllerRepresentable {

//    typealias UIViewControllerType = UIDocumentPickerViewController
    @Binding var isShown: Bool
    @Binding var doc: NSObject?

    func makeCoordinator() -> DocPickerView.DocCoordinator {
            print("make docCoordinator")
           return DocCoordinator(isShown: $isShown, doc: $doc, self)
       }
    
    //coordinator acts as the go between for swiftui and uikit
    
    class DocCoordinator: NSObject, UINavigationControllerDelegate, UIDocumentPickerDelegate {

        @Binding var docInCoordinator: NSObject?
        @Binding var isDocCoordinatorShown: Bool
        var parent: DocPickerView
        init(isShown: Binding<Bool>, doc: Binding<NSObject?>, _ pickerController: DocPickerView) {
            _isDocCoordinatorShown = isShown
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
    
    //initialize docPicker with specified document types and mode as import
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        print("make UIViewController called")
        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        docPicker.delegate = context.coordinator
        return docPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController,
                                context: UIViewControllerRepresentableContext<DocPickerView>) { }
}
