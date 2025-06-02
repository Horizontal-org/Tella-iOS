//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import UIKit
import SwiftUI

enum DocumentPickerType{
    case forExport
    case forImport
    
}

//  Setting up wrapper for UIDocumentPickerViewController
struct DocumentPickerView: UIViewControllerRepresentable {
    
    var documentPickerType : DocumentPickerType
    var URLs: [URL] = []
    let completion: ([URL]?) -> ()
    
    func makeCoordinator() -> DocumentCoordinator {
        return DocumentCoordinator(completion)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        var picker : UIDocumentPickerViewController
        
        switch documentPickerType {
            
        case .forExport:
            picker = UIDocumentPickerViewController(forExporting: URLs, asCopy: true)
            
        case .forImport:
            picker = UIDocumentPickerViewController()
            picker.allowsMultipleSelection = true
        }
        picker.delegate = context.coordinator
        
        return picker
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
    var fileData: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: fileData, applicationActivities: applicationActivities)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
