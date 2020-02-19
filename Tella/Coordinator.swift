//
//  Coordinator.swift
//  Tella
//
//  Created by Erin Simshauser on 2/18/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI
import Photos

class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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
        print("a")
        //getting the image url from user selection
        guard let metadata = info[UIImagePickerController.InfoKey.imageURL] as? NSURL else { print("c");  return }
        print("b")
        imageInCoordinator = Image(uiImage: unwrapImage)
        isCoordinatorShown = false
        
        print(metadata)
        //maintain a list of the files somewhere and then append the file to that list
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isCoordinatorShown = false
        
    }
}
