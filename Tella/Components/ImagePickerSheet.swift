//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import PhotosUI

enum MediaType {
    case video
    case image
}

struct ImagePickerSheet: UIViewControllerRepresentable {
    
    let completion: ([PHAsset]?) -> ()
    
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
    
    let completion: ([PHAsset]?) -> ()
    
    init(_ completion: @escaping ([PHAsset]?) -> ()) {
        self.completion = completion
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        let identifiers = results.compactMap(\.assetIdentifier)
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        var assets : [PHAsset] = []
        fetchResult.enumerateObjects { (asset, _, _) in
            assets.append(asset)
        }
        completion(assets)
    }
    
    func pickerDidCancel(_ picker: PHPickerViewController) {
        completion(nil)
    }
}

