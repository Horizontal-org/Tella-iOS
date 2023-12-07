//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import Photos
import MobileCoreServices


struct ImagePickerCompletion {
    enum MediaType {
        case video
        case image
    }
    let type: MediaType
    var referenceURL: URL? = nil
    var mediaURL: URL? = nil

}

//  SwiftUI wrapper for ImagePickerController for <= iOS 14.0
struct ImagePickerSheet: UIViewControllerRepresentable {
    
    let completion: (ImagePickerCompletion?) -> ()

    func makeCoordinator() -> ImageCoordinator {
      return ImageCoordinator(completion)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerSheet>) ->
        UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.mediaTypes = [(kUTTypeImage as String), (kUTTypeMovie as String)];
            return picker
    }

    //  this function must be here in order to fulfill recquirements, but nothing needs to go inside
    func updateUIViewController(_ uiViewController: UIImagePickerController,
                                context: UIViewControllerRepresentableContext<ImagePickerSheet>) {
    }
}

//  Creating the Coordinator (the go between) for the ImagePicker
class ImageCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let completion: (ImagePickerCompletion?) -> ()
    
    init(_ completion: @escaping (ImagePickerCompletion?) -> ()) {
        self.completion = completion
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let referenceURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL
        let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
       
        if mediaType as! CFString == kUTTypeImage {
            completion(ImagePickerCompletion(type: .image, referenceURL: referenceURL, mediaURL: imageURL))
        } else if mediaType as! CFString == kUTTypeMovie {
            completion(ImagePickerCompletion(type: .video, referenceURL: referenceURL, mediaURL: mediaURL))
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion(nil)
    }
}

