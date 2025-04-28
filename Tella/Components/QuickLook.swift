//
//  QuickLook.swift
//  Tella
//
//  Created by Erin Simshauser on 3/7/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This class is used to make the QLPreviewController compatabile with SwiftUI. The QL framework allows for easy in app viewing of any filetype. QuickLook just requires a url and then provides the appropriate view (PDF, doc, image, video, audio)
 This class is not currently in use because we only have access to unencrypted files in the form of data, not url. However, this file is still included in case a solution is found wherein files can be securely temporarily stored. Then all that is required is to pass in a url and a previewer will be created.
 */

import Foundation
import SwiftUI
import QuickLook

struct QuickLookView: UIViewControllerRepresentable {
    
    var file: URL
    
    func makeCoordinator() -> QuickLookView.Coordinator {
        Coordinator(self, file: file)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator
        
        let navController = UINavigationController(rootViewController: previewController)
        navController.navigationBar.isHidden = true // Hide the parent navigation bar
        return navController
    }
    
    func updateUIViewController(_ controller: UINavigationController,
                                context: Context) {
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: QuickLookView
        let file: URL
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return file as QLPreviewItem
        }
        
        init(_ parent: QuickLookView, file: URL) {
            self.parent = parent
            self.file = file
            super.init()
        }
        
        //  The QLPreviewController asks its delegate how many items it has:
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
    }
}
