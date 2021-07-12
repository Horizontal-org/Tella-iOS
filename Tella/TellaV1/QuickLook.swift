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
//  Properties: the file name (without extension), and whether we'll let
//  the user scale the preview content.
    var name: String
    var allowScaling: Bool = true
    var file: NSURL
      
    func makeCoordinator() -> QuickLookView.Coordinator {
    //  The coordinator object implements the mechanics of dealing with
    //  the live UIKit view controller.
        Coordinator(self, file: file)
    }
      
    func makeUIViewController(context: Context) -> QLPreviewController {
    //  Create the preview controller, and assign our Coordinator class
    //  as its data source.
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
      
    func updateUIViewController(_ controller: QLPreviewController,
                                context: Context) {
        // nothing to do here
    }
      
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let parent: QuickLookView
        let file: NSURL
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        //  NSURL objects can be returned as QLPreviewItems
            return file
        }

          
        init(_ parent: QuickLookView, file: NSURL) {
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
  
