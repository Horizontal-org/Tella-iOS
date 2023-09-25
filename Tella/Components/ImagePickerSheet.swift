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
    var image: UIImage?
    var videoURL: URL?
    var pathExtension: String?
    var referenceURL: URL?
    var imageURL: URL?
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
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
            let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            let referenceURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL
            let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
            if mediaType as! CFString == kUTTypeImage {
                guard let unwrapImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                    return
                }
                completion(ImagePickerCompletion(type: .image,image: unwrapImage,
                                                 pathExtension: mediaURL?.pathExtension,
                                                 referenceURL: referenceURL,
                                                 imageURL: imageURL))
            } else if mediaType as! CFString == kUTTypeMovie {
                guard let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL else {
                    return
                }
                completion(ImagePickerCompletion(type: .video, videoURL: videoURL, referenceURL: referenceURL))
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion(nil)
    }
}

