//
//  EditImageView.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Mantis

struct EditImageView: View {
    
    @EnvironmentObject var mainAppModel: MainAppModel
    
    var imageData : Data
    @State var image: UIImage? = (UIImage(named: "food") ?? UIImage())
//    @State private var cropRect: CGRect = .zero
    @Binding var isPresented : Bool
//    @State private var rotationAngle: Double = 0.0
//    @State private var rotatedImage: UIImage?
    var currenFile: VaultFileDB?
    var parentId: String?
    var body: some View {
        ZStack {
            VStack {
                
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image("close")
                    }
                    Spacer()
                    Button {
                        // Save changes

                    } label: {
                        Image("file.edit.done")
                    }
                }
                .padding(.top, 50)
                Spacer()
                ImageCropper(image: $image)
                    .padding(0)
                
                Spacer()
                HStack {
                    Spacer()
                    
                    Button {


                    } label: {
                        Image("edit.rotate")
                    }
                    Spacer()
                }
                .padding(.bottom, 50)                
            }
            .background(Color.black)
            .ignoresSafeArea()
        }
    }

    
}

class  ImageEditorCoordinator: NSObject, CropViewControllerDelegate {
    
    @Binding var theImage: UIImage
    //  @Binding var isShowing: Bool
    
    init(image: Binding<UIImage>) { //, isShowing: Binding<Bool>) {
        
        _theImage = image
        //        _isShowing = isShowing
    }
    
    func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
        theImage  = cropped
        //        isShowing = false
    }
    
    func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
        //        isShowing  = false
    }
    
}


struct ImageCropper: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: CropViewControllerDelegate {
        var parent: ImageCropper
        
        init(_ parent: ImageCropper) {
            self.parent = parent
        }
        
        func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            parent.image = cropped
            print("transformation is \(transformation)")
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        var config = Mantis.Config()
        config.showAttachedCropToolbar = false
        let cropViewController: CustomCropViewController = Mantis.cropViewController(image: image!, config: config)
        cropViewController.delegate = context.coordinator
        return UINavigationController(rootViewController: cropViewController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}


class CustomCropViewController: Mantis.CropViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let rotate = UIBarButtonItem(
            image: UIImage.init(named: "close")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(onRotateClicked)
        )

        let done = UIBarButtonItem(
            image: UIImage.init(named: "file.edit.done")?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(onDoneClicked)
        )
        navigationItem.rightBarButtonItem = done
        navigationItem.leftBarButtonItem = rotate
        
    }

    @objc private func onRotateClicked() {
        didSelectClockwiseRotate()
    }

    @objc private func onDoneClicked() {
        crop()
    }
    @objc private func onCloseClicked() {
        didSelectCancel()
    }
}
