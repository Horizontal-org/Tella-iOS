//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import Photos
import MobileCoreServices

//  SwiftUI wrapper for ImagePickerController for <= iOS 14.0
struct ImagePickerView: UIViewControllerRepresentable {
    
    let completion: (UIImage?, URL?, String?, URL?) -> ()

    func makeCoordinator() -> ImageCoordinator {
      return ImageCoordinator(completion)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) ->
        UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
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
    
    let completion: (UIImage?, URL?, String?, URL?) -> ()
    
    init(_ completion: @escaping (UIImage?, URL?, String?, URL?) -> ()) {
        self.completion = completion
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        debugLog("\(mediaType)")
        let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL
        if mediaType as! CFString == kUTTypeImage {
            guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }
            completion(unwrapImage, nil,mediaURL?.pathExtension, imageURL)
        } else if mediaType as! CFString == kUTTypeMovie {
            guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                return
            }
            completion(nil, videoURL, nil, nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion(nil, nil, nil, nil)
    }
}

