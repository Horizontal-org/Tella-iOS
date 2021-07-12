//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import SwiftUI

//  Setting up wrapper for UIDocumentPickerViewController
struct DocumentPickerView: UIViewControllerRepresentable {
    
    let completion: ([URL]?) -> ()

    func makeCoordinator() -> DocumentCoordinator {
        return DocumentCoordinator(completion)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        //  this allows any filetype to be imported
        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.item"], in: .import)
        docPicker.delegate = context.coordinator
        return docPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPickerView>) {}
}

//  Coordinator acts as the go between for swiftui and uikit
class DocumentCoordinator: NSObject, UINavigationControllerDelegate, UIDocumentPickerDelegate {

    let completion: ([URL]?) -> ()
    
    init(_ completion: @escaping ([URL]?) -> ()) {
        self.completion = completion
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        completion(urls)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion(nil)
    }

}

struct ActivityViewController: UIViewControllerRepresentable {
    var fileData: Data
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [fileData], applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
