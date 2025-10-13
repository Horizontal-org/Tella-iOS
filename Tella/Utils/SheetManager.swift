//  Tella
//
//  Copyright © 2022 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
    
    /// The backgroundColor of the sheet
    @Published var backgroundColor: Color = Styles.Colors.backgroundTab
    
    
    @Published var shouldHideOnTap: Bool = true
    
    
    init() {
        content = EmptyView().eraseToAnyView()
    }
    
    /**
     Updates the properties of the **Partial Sheet**
     */
    func showBottomSheet<T>(backgroundColor : Color = Styles.Colors.backgroundTab,
                            shouldHideOnTap: Bool = true,
                            content: (() -> T)) where T: View {
        
        self.isPresented = true
        self.content = AnyView(content())
        self.shouldHideOnTap = shouldHideOnTap
        self.backgroundColor = backgroundColor
    }
    
    func hide() {
        self.isPresented = false
    }
}
