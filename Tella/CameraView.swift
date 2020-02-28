//
//  CameraView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct CameraView: View {
    
    let back: () -> ()
    
    var body: some View {
        CaptureImageView(back: back)
    }
}

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

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let back: () -> ()
    
    init(_ back: @escaping () -> ()) {
        self.back = back
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrappedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        TellaFileManager.saveImage(unwrappedImage)
        back()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        back()
    }
}
