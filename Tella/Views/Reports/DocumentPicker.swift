//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//
import SwiftUI
import UIKit

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileContent: String
    @Binding var showModel: Bool
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(fileContant: $fileContent, isShow: $showModel)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .image, .png, .pdf, .pkcs12, .appleProtectedMPEG4Audio, .appleProtectedMPEG4Audio])
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }
}

class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
    @Binding var fileContentPath: String
    @Binding var showModel: Bool
    
    init(fileContant: Binding<String>, isShow: Binding<Bool>) {
        _fileContentPath = fileContant
        _showModel = isShow
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileUrl = urls.first else { return }
        do {
            fileContentPath = try String(contentsOf: fileUrl , encoding: .utf8)
            self.showModel = false
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
