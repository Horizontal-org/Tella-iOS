//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import PhotosUI

enum MediaType {
    case video
    case image
}

struct PHPickerCompletion {
    var assets : PHFetchResult<PHAsset>
}

struct ImagePickerSheet: UIViewControllerRepresentable {
    
    let completion: (PHPickerCompletion?) -> ()
    
    func makeCoordinator() -> ImageCoordinator {
        return ImageCoordinator(completion)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerSheet>) ->
    PHPickerViewController {

        let photoLibrary = PHPhotoLibrary.shared()
        
        var configuration = PHPickerConfiguration(photoLibrary: photoLibrary)
        configuration.selectionLimit = 0
        configuration.filter = .any(of: [.images, .videos])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    //  this function must be here in order to fulfill recquirements, but nothing needs to go inside
    func updateUIViewController(_ uiViewController: PHPickerViewController,
                                context: UIViewControllerRepresentableContext<ImagePickerSheet>) {
    }
}

//  Creating the Coordinator (the go between) for the PHPicker
class ImageCoordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    
    let completion: (PHPickerCompletion?) -> ()
    
    init(_ completion: @escaping (PHPickerCompletion?) -> ()) {
        self.completion = completion
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        completion(PHPickerCompletion(assets: fetchResult))
    }
    
    func pickerDidCancel(_ picker: PHPickerViewController) {
        completion(nil)
    }
}

