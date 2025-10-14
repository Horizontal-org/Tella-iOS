//
//  PopoverController.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct PopoverController<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let content: Content
    
    init(isPresented: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresented {
            let hostingController = CustomHostingView(rootView: content)
            hostingController.modalPresentationStyle = .popover
            if let popover = hostingController.popoverPresentationController {
                popover.delegate = context.coordinator
                popover.sourceView = uiViewController.view
                popover.sourceRect = CGRect(x: uiViewController.view.bounds.midX,
                                            y: uiViewController.view.bounds.minY,
                                            width: 0,
                                            height: 0)
                popover.permittedArrowDirections = .down
            }
            uiViewController.present(hostingController, animated: true)
        } else {
            uiViewController.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }
    
    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        @Binding var isPresented: Bool
        
        init(isPresented: Binding<Bool>) {
            self._isPresented = isPresented
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
        }
        
        func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
            isPresented = false
        }
    }
}

fileprivate class CustomHostingView<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePreferredContentSize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentSize()
    }
    
    private func updatePreferredContentSize() {
        let maxWidth: CGFloat = 300 
        let maxHeight: CGFloat = 400
        
        let targetSize = CGSize(width: maxWidth, height: UIView.layoutFittingCompressedSize.height)
        let calculatedSize = view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .defaultLow
        )
        
        let finalWidth = min(calculatedSize.width, maxWidth)
        let finalHeight = min(calculatedSize.height, maxHeight)
        preferredContentSize = CGSize(width: finalWidth, height: finalHeight)
    }
}
