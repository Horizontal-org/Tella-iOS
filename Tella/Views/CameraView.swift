//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CameraView: View {
    
    @ObservedObject var appModel: MainAppModel
    
    var body: some View {
        ZStack{
            CaptureImageView { image in
                guard let image = image else {
                    return
                }
                appModel.add(image: image, to: nil, type: .image)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

//  Setting uo the wrapper class for UIImagePickerController
struct CaptureImageView: UIViewControllerRepresentable {

    let completion: (UIImage?) -> ()
    
    func makeCoordinator() -> Coordinator {
        Coordinator (completion: completion)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureImageView>) ->
        UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            #if targetEnvironment(simulator)
                picker.sourceType = .photoLibrary
            #else
                picker.sourceType = .camera
            #endif
            return picker
        }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CaptureImageView>) {}
}

//  Coordinator which acts as the go between for UIKit and SwiftUI
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let completion: (UIImage?) -> ()

    init(completion: @escaping (UIImage?) -> ()) {
        self.completion = completion
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let unwrappedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        completion(unwrappedImage)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion(nil)
    }
}
