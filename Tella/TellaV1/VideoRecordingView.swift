//
//  VideoRecordingView.swift
//  Tella
//
//  Created by Abhishek Dave on 24/10/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI
import MobileCoreServices

struct VideoRecordingView: View {
    var body: some View {
        CaptureVideoView()
    }
}

//  Setting up the wrapper class for UIImagePickerController

struct CaptureVideoView: UIViewControllerRepresentable {
    @EnvironmentObject private var appViewState: AppViewState

    func makeCoordinator() -> VideoCoordinator {
        VideoCoordinator {
            self.appViewState.navigateBack()
        }
    }
    
    //Setting up VideoRecorder Presenter. Output video will be in MOV.
    func makeUIViewController(context: UIViewControllerRepresentableContext<CaptureVideoView>) ->
        UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.sourceType = .camera
            return picker
        }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<CaptureVideoView>) {}
}

//  Coordinator which acts as the go between for UIKit and SwiftUI
class VideoCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    
    // this function is called when a user finish recording the video.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let _:URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL) {
          //  TellaFileManager.saveVideo(selectedVideo)
         }

        completion()
    }

//  This function is called when a user cancels and returns them to the main page
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        completion()
    }
}
