//
//  QuickLook.swift
//  Tella
//
//  Created by Erin Simshauser on 3/7/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import Foundation
import SwiftUI
import QuickLook

protocol QLPreviewItem {
    var previewItemURL: URL? {get}
}

extension NSURL: QLPreviewItem {}



//https://medium.com/ios-os-x-development/ios-using-quicklook-for-fun-and-profit-d9a338e2f7fb
//Issue: we need to define our own QLPreviewItem

//@import QuickLook;
//@interface PreviewItem : NSObject <QLPreviewItem>
//@property(readonly, nullable, nonatomic) NSURL    *previewItemURL;
//@property(readonly, nullable, nonatomic) NSString *previewItemTitle;
//@end
//@implementation PreviewItem
//- (instancetype)initPreviewURL:(NSURL *)docURL
//                     WithTitle:(NSString *)title {
//    self = [super init];
//    if (self) {
//        _previewItemURL = [docURL copy];
//        _previewItemTitle = [title copy];
//    }
//    return self;
//}
  
struct QuickLookView: UIViewControllerRepresentable {
    // Properties: the file name (without extension), and whether we'll let
    // the user scale the preview content.
    var name: String
    var allowScaling: Bool = true
    var file: String
      
    func makeCoordinator() -> QuickLookView.Coordinator {
        // The coordinator object implements the mechanics of dealing with
        // the live UIKit view controller.
        Coordinator(self, file: file)
    }
      
    func makeUIViewController(context: Context) -> QLPreviewController {
        // Create the preview controller, and assign our Coordinator class
        // as its data source.
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
      
    func updateUIViewController(_ controller: QLPreviewController,
                                context: Context) {
        // nothing to do here
    }
      
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            guard let url = NSURL(string: file) else { return <#default value#> }
            return url
        }

    
        let parent: QuickLookView
        let file: String

          
        init(_ parent: QuickLookView, file: String) {
            self.parent = parent
            self.file = file
            super.init()
        }
          
        // The QLPreviewController asks its delegate how many items it has:
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }
          
        // For each item (see method above), the QLPreviewController asks for
        // a QLPreviewItem instance describing that item:
//        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
//            let url = NSURL(string: file)!
//            return url
//        }
    }
}
  
//struct QuickLookView_Previews: PreviewProvider {
//    static var previews: some View {
//        QuickLookView(name: "Preview")
//    }
//}
