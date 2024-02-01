//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftUI

struct RuntimeError: Error {
    
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}

extension RuntimeError: LocalizedError {
    
    public var errorDescription: String? {
        return message
    }
}

extension EdgeInsets {
    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

extension View {
    func customCardStyle() -> some View {
        self
            .background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
    }
}
