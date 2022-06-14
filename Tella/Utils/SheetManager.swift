//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

class SheetManager: ObservableObject {
    
    /// Published var to present or hide the partial sheet
    @Published var isPresented: Bool = false {
        didSet {
            if !isPresented {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                    self?.content = EmptyView().eraseToAnyView()
                }
            }
        }
    }
    /// The content of the sheet
    @Published var content: AnyView
    
    /// The height of the sheet
    @Published var modalHeight: CGFloat = 0
    
    /// The backgroundColor of the sheet
    @Published var backgroundColor: Color = Styles.Colors.backgroundTab

    
    @Published var shouldHideOnTap: Bool = true

    
    init() {
        content = EmptyView().eraseToAnyView()
    }
    
    /**
     Updates the properties of the **Partial Sheet**
     */
    func showBottomSheet<T>(modalHeight : CGFloat,
                            backgroundColor : Color = Styles.Colors.backgroundTab,
                            shouldHideOnTap: Bool = true,
                            content: (() -> T)) where T: View {
        
        self.isPresented = true
        self.content = AnyView(content())
        self.modalHeight = modalHeight
        self.shouldHideOnTap = shouldHideOnTap
        self.backgroundColor = backgroundColor
    }
    
    func hide() {
        self.isPresented = false
    }
}
