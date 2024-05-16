//
//  ImageCropper.swift
//  Tella
//
//  Created by RIMA on 16/5/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Mantis
import Combine

struct ImageCropper: UIViewControllerRepresentable {

    @Binding var image: UIImage?
    var didCropAction: () -> ()
    let didCancelAction: () -> ()
    
    func makeCoordinator() -> ImageCropperCoordinator {
        ImageCropperCoordinator(self, didCropAction, didCancelAction)
    }
    
     func makeUIViewController(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.cropToolbarConfig.toolbarButtonOptions = [ToolbarButtonOptions.counterclockwiseRotate]
        config.cropToolbarConfig.mode = .embedded
        config.cropViewConfig.showAttachedRotationControlView = false
        config.cropViewConfig.backgroundColor = .black
        let cropViewController: CustomCropViewController = Mantis.cropViewController(image: image!, config: config)
        cropViewController.delegate = context.coordinator
         let _ = cropViewController.isUpdatingImage.sink { value in
             context.coordinator.isUpdating = value
             cropViewController.crop()
         }.store(in: &context.coordinator.subscriptions)
        return UINavigationController(rootViewController: cropViewController)
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}


class ImageCropperCoordinator: CropViewControllerDelegate {
    var subscriptions =  Set<AnyCancellable>()
    var isUpdating = false
    var parent: ImageCropper
    var didCropAction: () -> ()
    let didCancelAction: () -> ()
    init(_ parent: ImageCropper,
         _ didCropAction: @escaping () -> (),
         _ didCancelAction: @escaping () -> ()) {
        self.parent = parent
        self.didCropAction = didCropAction
        self.didCancelAction = didCancelAction
    }
    
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
        parent.image = cropped
        if !isUpdating {
            didCropAction()
        }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        didCancelAction()
    }
}
