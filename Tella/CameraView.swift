//
//  CameraView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//
/*
 This class presents the camera view. It uses the UIImagePickerController UIKit class in order to allow users to capture photos directly through the app. The images will automatically be encrypted and saved only in the Tella app, not in the user's gallery.
 This class also relies on a wrapper class for a UIKit framework. We are using the UIImagePickerController again, but this one has different settings because we are using it to access camera instead of photos.
 */
import SwiftUI

struct CameraView: View {
    
    let back: () -> ()
    
    var body: some View {
        CaptureImageView(back: back)
    }
}

//  Setting uo the wrapper class for UIImagePickerController
struct CaptureImageView: UIViewControllerRepresentable {
    
    let back: () -> ()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(back)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) ->
        UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = .camera
            return picker
        }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CaptureImageView>) {}
}

//  Coordinator which acts as the go between for UIKit and SwiftUI
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let back: () -> ()
    
    init(_ back: @escaping () -> ()) {
        self.back = back
    }
//  This function is called when a user takes a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrappedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        //  saves the image taken by the camera to the internal Tella file manager
        TellaFileManager.saveImage(unwrappedImage)
        back()
    }

//  This function is called when a user cancels and returns them to the main page
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        back()
    }
}
