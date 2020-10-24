//
//  Coordinator.swift
//  Tella
//
//  Created by Erin Simshauser on 2/18/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This class is used in the Gallery class. At the time of writing, UIKit frameworks UIImagePickerController and UIDocumentPickerViewController were not integrated with SwiftUI. This class creates wrapper structs for those view controllers in order to make them presentable through SwiftUI.
 The key part to add is a Coordinator for each class. The Coordinator acts as the go between for UIKit and SwiftUI
 */
import SwiftUI
import Photos
import MobileCoreServices

//  Setting up wrapper for ImagePickerController
struct ImagePickerView: UIViewControllerRepresentable {
    
    let back: () -> ()

    func makeCoordinator() -> ImageCoordinator {
      return ImageCoordinator(back)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) ->
        UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            //  sets what types of files we can import, in this case images and videos
            picker.mediaTypes = [(kUTTypeImage as String), (kUTTypeMovie as String)];
            
            return picker
    }

    //  this function must be here in order to fulfill recquirements, but nothing needs to go inside
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePickerView>) {
    }
}

//  Creating the Coordinator (the go between) for the ImagePicker
class ImageCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let back: () -> ()
    
    init(_ back: @escaping () -> ()) {
        self.back = back
    }
    
//  this function gets called when user selects an image
    func imagePickerController(_ picker: UIImagePickerController,
                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        print(mediaType)
        //  save the file to internal Tella file manager which will automatically encrypt it
        if mediaType as! CFString == kUTTypeImage {
            guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            TellaFileManager.saveImage(unwrapImage)
        } else if mediaType as! CFString == kUTTypeMovie {
            guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }
            TellaFileManager.copyExternalFile(videoURL)
        }
        back()
    }
    
//  this function gets called when the user clicks the cancel button
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        back()
    }
}

//  Setting up wrapper for UIDocumentPickerViewController
struct DocPickerView: UIViewControllerRepresentable {
    
    let back: () -> ()

    func makeCoordinator() -> DocCoordinator {
        return DocCoordinator(back)
    }

//  Initialize docPicker with specified document types and mode as import
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        //  this allows any filetype to be imported
        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        docPicker.delegate = context.coordinator
        return docPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocPickerView>) {}
}

//  Coordinator acts as the go between for swiftui and uikit
class DocCoordinator: NSObject, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    let back: () -> ()
    
    init(_ back: @escaping () -> ()) {
        self.back = back
    }
    
//  this function called on document click
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        //  Saves the file to the internal Tella file manager
        guard let url = urls.first else {
            print("Failed to retrieve url")
            return
        }
        TellaFileManager.copyExternalFile(url)
        back()
    }
//  called when cancel button pressed
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        back()
    }

}

struct ActivityViewController: UIViewControllerRepresentable {

    var fileData: Data
    var fileType: FileTypeEnum
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        switch fileType {
        case .AUDIO:
            let filePath="\(documentsPath)/audioFromTella.aac"
            return controllerToShareMedia(with: filePath)
        case .VIDEO:
            let filePath="\(documentsPath)/videoFromTella.mov"
            return controllerToShareMedia(with: filePath)
        default:
            let controller = UIActivityViewController(activityItems: [fileData], applicationActivities: applicationActivities)
            return controller
        }

    }
    
    func controllerToShareMedia(with filePath: String) -> UIActivityViewController {
        let mediaData = fileData as NSData
        mediaData.write(toFile: filePath, atomically: true)
        let activityVC = UIActivityViewController(activityItems: [NSURL(fileURLWithPath: filePath)], applicationActivities: nil)
        return activityVC
    }
    
    

    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
